-- 删除原有的vital_signs_addition表（如果存在）
DROP TABLE IF EXISTS vital_signs_addition;

-- 创建vital_signs_addition表
CREATE TABLE vital_signs_addition AS
WITH nc AS (
    SELECT
        nc.patientunitstayid,
        nc.nursingchartoffset,
        nc.nursingchartentryoffset
        -- Define each vital sign as a case statement to ensure it's numeric and within an expected range
        -- pivot data - choose column names for consistency with vitalperiodic
    , case
            WHEN nursingchartcelltypevallabel = 'PA'
            AND  nursingchartcelltypevalname = 'PA Systolic'
            -- verify it's numeric
            AND nursingchartvalue ~ '^[-]?[0-9]+[.]?[0-9]*$' and nursingchartvalue not in ('-','.')
            then cast(nursingchartvalue as numeric)
        else null end
        as pasystolic
    , case
            WHEN nursingchartcelltypevallabel = 'PA'
            AND  nursingchartcelltypevalname = 'PA Diastolic'
            -- verify it's numeric
            AND nursingchartvalue ~ '^[-]?[0-9]+[.]?[0-9]*$' and nursingchartvalue not in ('-','.')
            then cast(nursingchartvalue as numeric)
        else null end
        as padiastolic
    , case
            WHEN nursingchartcelltypevallabel = 'PA'
            AND  nursingchartcelltypevalname = 'PA Mean'
            -- verify it's numeric
            AND nursingchartvalue ~ '^[-]?[0-9]+[.]?[0-9]*$' and nursingchartvalue not in ('-','.')
            then cast(nursingchartvalue as numeric)
        else null end
        as pamean
    , case
            WHEN nursingchartcelltypevallabel = 'SV'
            AND  nursingchartcelltypevalname = 'SV'
            -- verify it's numeric
            AND nursingchartvalue ~ '^[-]?[0-9]+[.]?[0-9]*$' and nursingchartvalue not in ('-','.')
            then cast(nursingchartvalue as numeric)
        else null end
        as sv
    , case
            WHEN nursingchartcelltypevallabel = 'CO'
            AND  nursingchartcelltypevalname = 'CO'
            -- verify it's numeric
            AND nursingchartvalue ~ '^[-]?[0-9]+[.]?[0-9]*$' and nursingchartvalue not in ('-','.')
            then cast(nursingchartvalue as numeric)
        else null end
        as co
    , case
            WHEN nursingchartcelltypevallabel = 'SVR'
            AND  nursingchartcelltypevalname = 'SVR'
            -- verify it's numeric
            AND nursingchartvalue ~ '^[-]?[0-9]+[.]?[0-9]*$' and nursingchartvalue not in ('-','.')
            then cast(nursingchartvalue as numeric)
        else null end
        as svr
    , case
            WHEN nursingchartcelltypevallabel = 'ICP'
            AND  nursingchartcelltypevalname = 'ICP'
            -- verify it's numeric
            AND nursingchartvalue ~ '^[-]?[0-9]+[.]?[0-9]*$' and nursingchartvalue not in ('-','.')
            then cast(nursingchartvalue as numeric)
        else null end
        as icp
    , case
            WHEN nursingchartcelltypevallabel = 'CI'
            AND  nursingchartcelltypevalname = 'CI'
            -- verify it's numeric
            AND nursingchartvalue ~ '^[-]?[0-9]+[.]?[0-9]*$' and nursingchartvalue not in ('-','.')
            then cast(nursingchartvalue as numeric)
        else null end
        as ci
    , case
            WHEN nursingchartcelltypevallabel = 'SVRI'
            AND  nursingchartcelltypevalname = 'SVRI'
            -- verify it's numeric
            AND nursingchartvalue ~ '^[-]?[0-9]+[.]?[0-9]*$' and nursingchartvalue not in ('-','.')
            then cast(nursingchartvalue as numeric)
        else null end
        as svri
    , case
            WHEN nursingchartcelltypevallabel = 'CPP'
            AND  nursingchartcelltypevalname = 'CPP'
            -- verify it's numeric
            AND nursingchartvalue ~ '^[-]?[0-9]+[.]?[0-9]*$' and nursingchartvalue not in ('-','.')
            then cast(nursingchartvalue as numeric)
        else null end
        as cpp
    , case
            WHEN nursingchartcelltypevallabel = 'SVO2'
            AND  nursingchartcelltypevalname = 'SVO2'
            -- verify it's numeric
            AND nursingchartvalue ~ '^[-]?[0-9]+[.]?[0-9]*$' and nursingchartvalue not in ('-','.')
            then cast(nursingchartvalue as numeric)
        else null end
        as svo2
    , case
            WHEN nursingchartcelltypevallabel = 'PAOP'
            AND  nursingchartcelltypevalname = 'PAOP'
            -- verify it's numeric
            AND nursingchartvalue ~ '^[-]?[0-9]+[.]?[0-9]*$' and nursingchartvalue not in ('-','.')
            then cast(nursingchartvalue as numeric)
        else null end
        as paop
    , case
            WHEN nursingchartcelltypevallabel = 'PVR'
            AND  nursingchartcelltypevalname = 'PVR'
            -- verify it's numeric
            AND nursingchartvalue ~ '^[-]?[0-9]+[.]?[0-9]*$' and nursingchartvalue not in ('-','.')
            then cast(nursingchartvalue as numeric)
        else null end
        as pvr
    , case
            WHEN nursingchartcelltypevallabel = 'PVRI'
            AND  nursingchartcelltypevalname = 'PVRI'
            -- verify it's numeric
            AND nursingchartvalue ~ '^[-]?[0-9]+[.]?[0-9]*$' and nursingchartvalue not in ('-','.')
            then cast(nursingchartvalue as numeric)
        else null end
        as pvri
    , case
        WHEN nursingchartcelltypevallabel = 'IAP'
        AND  nursingchartcelltypevalname = 'IAP'
        -- verify it's numeric
        AND nursingchartvalue ~ '^[-]?[0-9]+[.]?[0-9]*$' and nursingchartvalue not in ('-','.')
            then cast(nursingchartvalue as numeric)
        else null end
    as iap
    FROM eicu_crd.nursecharting nc
    INNER JOIN csv_table csv ON nc.patientunitstayid = csv.patientid
    WHERE nc.nursingchartcelltypecat = 'Vital Signs'
),
aggregated AS (
    SELECT
        patientunitstayid,
        nursingchartoffset AS chartoffset,
        nursingchartentryoffset AS entryoffset
        -- Calculate the average for each vital sign to aggregate measurements taken at similar times
        , AVG(pasystolic) AS avg_pasystolic
        , AVG(padiastolic) AS avg_padiastolic
        , AVG(CASE WHEN pamean >= 0 AND pamean <= 1000 THEN pamean ELSE NULL END) AS pamean
        , AVG(CASE WHEN sv >= 0 AND sv <= 1000 THEN sv ELSE NULL END) AS sv
        , AVG(CASE WHEN co >= 0 AND co <= 1000 THEN co ELSE NULL END) AS co
        , AVG(CASE WHEN svr >= 0 AND svr <= 1000 THEN svr ELSE NULL END) AS svr
        , AVG(CASE WHEN icp >= 0 AND icp <= 1000 THEN icp ELSE NULL END) AS icp
        , AVG(CASE WHEN ci >= 0 AND ci <= 1000 THEN ci ELSE NULL END) AS ci
        , AVG(CASE WHEN svri >= 0 AND svri <= 1000 THEN svri ELSE NULL END) AS svri
        , AVG(CASE WHEN cpp >= 0 AND cpp <= 1000 THEN cpp ELSE NULL END) AS cpp
        , AVG(CASE WHEN svo2 >= 0 AND svo2 <= 1000 THEN svo2 ELSE NULL END) AS svo2
        , AVG(CASE WHEN paop >= 0 AND paop <= 1000 THEN paop ELSE NULL END) AS paop
        , AVG(CASE WHEN pvr >= 0 AND pvr <= 1000 THEN pvr ELSE NULL END) AS pvr
        , AVG(CASE WHEN pvri >= 0 AND pvri <= 1000 THEN pvri ELSE NULL END) AS pvri
        , AVG(CASE WHEN iap >= 0 AND iap <= 1000 THEN iap ELSE NULL END) AS iap
    FROM nc
    GROUP BY patientunitstayid, nursingchartoffset, nursingchartentryoffset
)
SELECT * FROM aggregated
ORDER BY patientunitstayid, chartoffset, entryoffset;

-- 将vital_signs_addition表中的数据导出到CSV文件
COPY vital_signs_addition TO '/home/hwxu/Projects/Dataset/PKU/eICU/csv/vital_signs_addition.csv' DELIMITER ',' CSV HEADER;
