-- Assumption: The 'aki_cr' and 'aki_uo' tables have been defined earlier as per the provided scripts.

CREATE OR REPLACE FUNCTION DATETIME_SUB(datetime_val TIMESTAMP(3), intvl INTERVAL) RETURNS TIMESTAMP(3) AS $$
BEGIN
    RETURN datetime_val - intvl;
END; $$
LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION DATETIME_DIFF(endtime TIMESTAMP(3), starttime TIMESTAMP(3), datepart TEXT) RETURNS NUMERIC AS $$
BEGIN
    RETURN 
        EXTRACT(EPOCH FROM endtime - starttime) /
        CASE
            WHEN datepart = 'SECOND' THEN 1.0
            WHEN datepart = 'MINUTE' THEN 60.0
            WHEN datepart = 'HOUR' THEN 3600.0
            WHEN datepart = 'DAY' THEN 24*3600.0
            WHEN datepart = 'YEAR' THEN 365.242*24*3600.0
        ELSE NULL END;
END; $$
LANGUAGE PLPGSQL;

DROP TABLE IF EXISTS aki_final;
CREATE TABLE aki_final AS
-- Identify patients who started RRT before ICU admission
WITH pre_icu_rrt AS (
    SELECT
        crrt.stay_id
        , MIN(crrt.charttime) AS first_crrt_time
    FROM mimiciv_derived.crrt crrt
    WHERE crrt.crrt_mode IS NOT NULL
    GROUP BY crrt.stay_id
)

, icu_admit AS (
    SELECT
        ie.stay_id
        , ie.intime AS icu_intime
    FROM mimiciv_icu.icustays ie
)

, icu_rrt AS (
    SELECT
        pre.stay_id
        , CASE WHEN pre.first_crrt_time < ia.icu_intime THEN TRUE ELSE FALSE END AS rrt_pre_icu
    FROM pre_icu_rrt pre
    JOIN icu_admit ia ON pre.stay_id = ia.stay_id
)

-- Combine AKI status based on creatinine and urine output
, combined_aki AS (
    SELECT
        cr.hadm_id
        , cr.stay_id
        , cr.aki_status AS aki_status_cr
        , uo.aki_status AS aki_status_uo
        , rrt.rrt_pre_icu
    FROM aki_cr cr
    LEFT JOIN aki_uo uo ON cr.stay_id = uo.stay_id
    LEFT JOIN icu_rrt rrt ON cr.stay_id = rrt.stay_id
)
, final_aki AS (
    SELECT
        stay_id AS patientunitstayid
        , CASE 
            WHEN (aki_status_cr = 'AKI' OR aki_status_uo = 'AKI') AND COALESCE(rrt_pre_icu, FALSE) = FALSE
            THEN 'ICU Acquired AKI'
            ELSE 'No ICU Acquired AKI'
          END AS final_aki_status
    FROM combined_aki
    GROUP BY stay_id, aki_status_cr, aki_status_uo, rrt_pre_icu
)

SELECT
    patientunitstayid
    , final_aki_status
FROM final_aki;

COPY aki_final TO '/home/hwxu/Projects/Dataset/PKU/mimic/csv/aki_mimic.csv' DELIMITER ',' CSV HEADER;
