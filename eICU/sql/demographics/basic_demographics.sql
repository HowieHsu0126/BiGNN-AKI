-- 创建demographics表
CREATE TABLE IF NOT EXISTS demographics (
    patientunitstayid INT PRIMARY KEY,
    age VARCHAR(50),
    gender INT,
    height NUMERIC,
    weight NUMERIC
);

-- 使用CTE来计算并修正身高和体重
WITH htwt AS (
    SELECT
        pt.patientunitstayid,
        pt.hospitaladmitoffset AS chartoffset,
        pt.admissionheight AS height,
        pt.admissionweight AS weight,
        CASE
            WHEN pt.admissionweight >= 100 AND pt.admissionheight > 25 AND pt.admissionheight <= 100 AND ABS(pt.admissionheight - pt.admissionweight) >= 20 THEN 'swap'
        END AS method
    FROM eicu_crd.patient pt
    INNER JOIN csv_table csv ON pt.patientunitstayid = csv.patientid
),
htwt_fixed AS (
    SELECT
        patientunitstayid,
        chartoffset,
        CASE
            WHEN method = 'swap' THEN weight
            WHEN height <= 0.30 THEN NULL
            WHEN height <= 2.5 THEN height * 100
            WHEN height <= 10 THEN NULL
            WHEN height <= 25 THEN height * 10
            WHEN height <= 100 AND ABS(height - weight) < 20 THEN NULL
            WHEN height > 250 THEN NULL
            ELSE height
        END AS height_fixed,
        CASE
            WHEN method = 'swap' THEN height
            WHEN weight <= 20 THEN NULL
            WHEN weight > 300 THEN NULL
            ELSE weight
        END AS weight_fixed
    FROM htwt
)

-- 将查询结果插入demographics表
INSERT INTO demographics (patientunitstayid, age, gender, height, weight)
SELECT 
    pt.patientunitstayid, 
    pt.age, 
    CASE 
        WHEN pt.gender = 'Male' THEN 1
        WHEN pt.gender = 'Female' THEN 2
        ELSE NULL 
    END AS gender,
    hf.height_fixed AS height,
    hf.weight_fixed AS weight
FROM 
    eicu_crd.patient pt
INNER JOIN 
    csv_table csv ON pt.patientunitstayid = csv.patientid
INNER JOIN 
    htwt_fixed hf ON pt.patientunitstayid = hf.patientunitstayid
WHERE 
    hf.height_fixed IS NOT NULL AND hf.weight_fixed IS NOT NULL
ON CONFLICT (patientunitstayid) DO NOTHING;

-- 将demographics表中的数据导出到CSV文件
COPY demographics TO '/home/hwxu/Projects/Dataset/PKU/eICU/csv/demographics.csv' DELIMITER ',' CSV HEADER;
