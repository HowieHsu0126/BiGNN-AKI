-- 提供一个综合了两种诊断方法（肌酐和尿量）的AKI状态列表。
-- 如果aki_creat视图显示在48小时或7天内存在AKI，或者aki_uo视图显示存在AKI，则将最终状态标记为'AKI'。
-- 否则，将最终状态标记为'Non-AKI'。

-- 删除已存在的表格以避免重复
DROP TABLE IF EXISTS final_aki_status;

-- 创建最终AKI状态表，同时考虑RRT状态
CREATE TABLE final_aki_status AS
SELECT
    cr.patientunitstayid,
    cr.aki_status AS aki_status_cr,
    uo.aki_status AS aki_status_uo,
    CASE
        WHEN rrt.patientunitstayid IS NOT NULL THEN 'AKI'  -- 如果在ICU前接受了RRT，则标记为AKI
        ELSE CASE
            WHEN cr.aki_status LIKE 'AKI%' OR uo.aki_status = 'AKI' THEN 'AKI'
            ELSE 'Non-AKI'
        END
    END AS final_aki_status,
    CASE 
        WHEN rrt.patientunitstayid IS NOT NULL THEN 'AKI'  -- 标记RRT AKI状态
        ELSE 'Non-AKI'
    END AS rrt_aki_status
FROM
    aki_cr cr
LEFT JOIN
    aki_uo uo ON cr.patientunitstayid = uo.patientunitstayid
LEFT JOIN
    aki_rrt rrt ON cr.patientunitstayid = rrt.patientunitstayid;

-- 将最终的AKI状态数据导出到CSV文件
COPY final_aki_status TO '/home/hwxu/Projects/Dataset/PKU/eICU/csv/aki_eicu.csv' DELIMITER ',' CSV HEADER;
