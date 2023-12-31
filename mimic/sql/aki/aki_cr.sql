CREATE OR REPLACE FUNCTION DATETIME_SUB(datetime_val TIMESTAMP(3), intvl INTERVAL) RETURNS TIMESTAMP(3) AS $$
BEGIN
RETURN datetime_val - intvl;
END; $$
LANGUAGE PLPGSQL;

DROP TABLE IF EXISTS aki_cr;
CREATE TABLE aki_cr AS
-- Extract all creatinine values from labevents within a 90-day window around patient's ICU stay
WITH cr AS (
    SELECT
        ie.hadm_id
        , ie.stay_id
        , le.charttime
        , le.valuenum AS creat
    FROM mimiciv_icu.icustays ie
    LEFT JOIN mimiciv_hosp.labevents le
        ON ie.subject_id = le.subject_id
            AND le.itemid = 50912
            AND le.valuenum IS NOT NULL
            AND le.valuenum <= 150
            AND le.charttime >= DATETIME_SUB(ie.intime, INTERVAL '90' DAY)
            AND le.charttime <= ie.outtime
)

, cr_avg AS (
    -- Calculate the average creatinine value for each patient over the 90-day window
    SELECT
        hadm_id
        , AVG(creat) AS avg_creat
    FROM cr
    GROUP BY hadm_id
)

, cr_baseline AS (
    -- Select the creatinine value closest to the average for each patient as the baseline
    SELECT
        cr.hadm_id
        , cr.stay_id
        , cr.charttime
        , cr.creat
        , ABS(cr.creat - cr_avg.avg_creat) AS diff
    FROM cr
    INNER JOIN cr_avg
        ON cr.hadm_id = cr_avg.hadm_id
)

, ranked_baseline AS (
    -- Rank the creatinine values by their closeness to the average
    SELECT
        hadm_id
        , stay_id
        , charttime AS baseline_time
        , creat AS baseline_creat
        , ROW_NUMBER() OVER(PARTITION BY hadm_id ORDER BY diff ASC) AS rank
    FROM cr_baseline
)

, cr_48hr_max AS (
    -- Determine the highest creatinine value within 48 hours after ICU admission
    SELECT
        cr.hadm_id
        , MAX(cr.creat) AS max_creat_48hr
    FROM cr
    JOIN ranked_baseline rb
        ON cr.hadm_id = rb.hadm_id
        AND cr.charttime BETWEEN rb.baseline_time AND DATETIME_SUB(rb.baseline_time, INTERVAL '-48' HOUR)
    GROUP BY cr.hadm_id
)

, cr_7day_max AS (
    -- Determine the highest creatinine value within 7 days after ICU admission
    SELECT
        cr.hadm_id
        , MAX(cr.creat) AS max_creat_7day
    FROM cr
    JOIN ranked_baseline rb
        ON cr.hadm_id = rb.hadm_id
        AND cr.charttime BETWEEN rb.baseline_time AND DATETIME_SUB(rb.baseline_time, INTERVAL '-7' DAY)
    GROUP BY cr.hadm_id
)

, aki_status AS (
    -- Determine AKI status based on KDIGO criteria
    SELECT
        rb.hadm_id
        , rb.stay_id
        , rb.baseline_time
        , rb.baseline_creat
        , c48.max_creat_48hr
        , c7.max_creat_7day
        , CASE
            WHEN c48.max_creat_48hr >= rb.baseline_creat + 0.3 OR c48.max_creat_48hr >= 1.5 * rb.baseline_creat THEN 'AKI within 48hr'
            WHEN c7.max_creat_7day >= 1.5 * rb.baseline_creat THEN 'AKI within 7day'
            ELSE 'No AKI'
          END AS aki_status
    FROM ranked_baseline rb
    LEFT JOIN cr_48hr_max c48
        ON rb.hadm_id = c48.hadm_id
    LEFT JOIN cr_7day_max c7
        ON rb.hadm_id = c7.hadm_id
    WHERE rb.rank = 1
)

SELECT *
FROM aki_status;
