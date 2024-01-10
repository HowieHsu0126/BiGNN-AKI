DROP TABLE IF EXISTS csv_table;
CREATE TABLE csv_table (
    patientid INT PRIMARY KEY
);
COPY csv_table(patientid)
FROM '/home/hwxu/Projects/Dataset/PKU/eICU/csv/aki_eicu_id.csv'
DELIMITER ','
CSV HEADER;
