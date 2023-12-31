-- 提供一个综合了两种诊断方法（肌酐和尿量）的AKI状态列表。
-- 如果aki_creat视图显示在48小时或7天内存在AKI，或者aki_uo视图显示存在AKI，则将最终状态标记为'AKI'。
-- 否则，将最终状态标记为'Non-AKI'。

-- 删除已存在的表格以避免重复
DROP TABLE IF EXISTS final_aki_status;

-- 创建最终AKI状态表，同时考虑RRT状态
CREATE TABLE final_aki_status AS
SELECT 
    ac.patientunitstayid,
    CASE 
        WHEN (ac.aki_status = 'AKI within 48h' OR ac.aki_status = 'AKI within 7days' OR uo.aki_status = 'AKI') 
             AND rrt.patientunitstayid IS NULL THEN 'ICU Acquired AKI'
        ELSE 'No ICU Acquired AKI' 
    END AS final_aki_status
FROM aki_cr ac
LEFT JOIN aki_uo uo ON ac.patientunitstayid = uo.patientunitstayid
LEFT JOIN aki_rrt rrt ON ac.patientunitstayid = rrt.patientunitstayid
GROUP BY ac.patientunitstayid, final_aki_status
ORDER BY ac.patientunitstayid;


-- 将最终的AKI状态数据导出到CSV文件
COPY final_aki_status TO '/home/hwxu/Projects/Dataset/PKU/eICU/csv/aki_eicu.csv' DELIMITER ',' CSV HEADER;
