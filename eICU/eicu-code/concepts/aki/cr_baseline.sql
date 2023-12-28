-- 用于确定基线肌酐水平
-- 目的: 确定患者在进入ICU前3个月内至ICU入住时的首个肌酐值。
-- 操作: 使用WITH语句创建一个临时表，筛选出肌酐实验室结果，并通过ROW_NUMBER()函数按照时间顺序对每个患者的结果进行排序。最终选择每个患者的第一个肌酐值及其对应的时间偏移量。

DROP VIEW IF EXISTS baseline_creat_view;
CREATE VIEW baseline_creat_view AS
WITH tempo AS (
    SELECT patientunitstayid,
           labname,
           labresultoffset,
           labresult,
           ROW_NUMBER() OVER (PARTITION BY patientunitstayid, labname ORDER BY labresultoffset ASC) AS POSITION
    FROM eicu_crd.lab
    WHERE labname = 'creatinine'
      AND labresultoffset BETWEEN -902460 AND 0
)
SELECT patientunitstayid,
       MAX(CASE WHEN labname = 'creatinine' AND POSITION = 1 THEN labresult ELSE NULL END) AS creat1,
       MAX(CASE WHEN labname = 'creatinine' AND POSITION = 1 THEN labresultoffset ELSE NULL END) AS creat1offset
FROM tempo
GROUP BY patientunitstayid
ORDER BY patientunitstayid;
