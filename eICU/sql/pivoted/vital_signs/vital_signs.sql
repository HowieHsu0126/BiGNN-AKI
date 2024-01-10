-- 删除原有的vital_signs表（如果存在）
DROP TABLE IF EXISTS vital_signs;

-- 创建vital_signs表
CREATE TABLE vital_signs AS
WITH nc AS (
    SELECT
        nc.patientunitstayid,
        nc.nursingchartoffset,
        nc.nursingchartentryoffset,
        -- Heart Rate
        CASE WHEN nursingchartcelltypevallabel = 'Heart Rate'
                AND nursingchartvalue ~ '^[0-9]+$' THEN cast(nursingchartvalue as numeric) ELSE null END AS heartrate,
        -- Respiratory Rate
        CASE WHEN nursingchartcelltypevallabel = 'Respiratory Rate'
                AND nursingchartvalue ~ '^[0-9]+$' THEN cast(nursingchartvalue as numeric) ELSE null END AS respiratoryrate,
        -- O2 Saturation
        CASE WHEN nursingchartcelltypevallabel = 'O2 Saturation'
                AND nursingchartvalue ~ '^[0-9]+$' THEN cast(nursingchartvalue as numeric) ELSE null END AS o2saturation,
        -- Non-Invasive BP Systolic
        CASE WHEN nursingchartcelltypevallabel = 'Non-Invasive BP'
                AND nursingchartcelltypevalname = 'Non-Invasive BP Systolic'
                AND nursingchartvalue ~ '^[0-9]+$' THEN cast(nursingchartvalue as numeric) ELSE null END AS nibp_systolic,
        -- Non-Invasive BP Diastolic
        CASE WHEN nursingchartcelltypevallabel = 'Non-Invasive BP'
                AND nursingchartcelltypevalname = 'Non-Invasive BP Diastolic'
                AND nursingchartvalue ~ '^[0-9]+$' THEN cast(nursingchartvalue as numeric) ELSE null END AS nibp_diastolic,
        -- Temperature
        CASE WHEN nursingchartcelltypevallabel = 'Temperature'
                AND nursingchartcelltypevalname = 'Temperature (C)'
                AND nursingchartvalue ~ '^[0-9]+(\.[0-9]+)?$' THEN cast(nursingchartvalue as numeric) ELSE null END AS temperature
    FROM eicu_crd.nursecharting nc
    INNER JOIN csv_table csv ON nc.patientunitstayid = csv.patientid
    WHERE nc.nursingchartcelltypecat IN ('Vital Signs','Scores','Other Vital Signs and Infusions')
),
aggregated AS (
    SELECT
        patientunitstayid,
        nursingchartoffset AS chartoffset,
        nursingchartentryoffset AS entryoffset,
        AVG(heartrate) AS avg_heartrate,
        AVG(respiratoryrate) AS avg_respiratoryrate,
        AVG(o2saturation) AS avg_o2saturation,
        AVG(nibp_systolic) AS avg_nibp_systolic,
        AVG(nibp_diastolic) AS avg_nibp_diastolic,
        AVG(temperature) AS avg_temperature
    FROM nc
    GROUP BY patientunitstayid, nursingchartoffset, nursingchartentryoffset
)
SELECT * FROM aggregated
ORDER BY patientunitstayid, chartoffset, entryoffset;

-- 将vital_signs表中的数据导出到CSV文件
COPY vital_signs TO '/home/hwxu/Projects/Dataset/PKU/eICU/csv/vital_signs.csv' DELIMITER ',' CSV HEADER;
