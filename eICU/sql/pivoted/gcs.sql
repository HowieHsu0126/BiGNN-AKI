CREATE OR REPLACE FUNCTION REGEXP_CONTAINS(str TEXT, pattern TEXT) RETURNS BOOL AS $$
BEGIN
RETURN str ~ pattern;
END; $$
LANGUAGE PLPGSQL;

DROP TABLE IF EXISTS pivoted_gcs;
CREATE TABLE pivoted_gcs AS
SELECT
    nc.patientunitstayid
    , nc.chartoffset
    , CASE WHEN nc.gcs > 2 AND nc.gcs < 16 THEN nc.gcs ELSE NULL END AS gcs
    , nc.gcsmotor, nc.gcsverbal, nc.gcseyes
FROM
    (
        SELECT
            patientunitstayid
            , nursingchartoffset AS chartoffset
            , MIN(CASE
                WHEN nursingchartcelltypevallabel = 'Glasgow coma score'
                    AND nursingchartcelltypevalname = 'GCS Total'
                    AND REGEXP_CONTAINS(nursingchartvalue, '^[-]?[0-9]+[.]?[0-9]*$')
                    AND nursingchartvalue NOT IN ('-','.')
                    THEN CAST(nursingchartvalue AS NUMERIC)
                WHEN nursingchartcelltypevallabel = 'Score (Glasgow Coma Scale)'
                    AND nursingchartcelltypevalname = 'Value'
                    AND REGEXP_CONTAINS(nursingchartvalue, '^[-]?[0-9]+[.]?[0-9]*$')
                    AND nursingchartvalue NOT IN ('-','.')
                    THEN CAST(nursingchartvalue AS NUMERIC)
                ELSE NULL END) AS gcs
            , MIN(CASE
                WHEN nursingchartcelltypevallabel = 'Glasgow coma score'
                    AND nursingchartcelltypevalname = 'Motor'
                    AND REGEXP_CONTAINS(nursingchartvalue, '^[-]?[0-9]+[.]?[0-9]*$')
                    AND nursingchartvalue NOT IN ('-','.')
                    THEN CAST(nursingchartvalue AS NUMERIC)
                ELSE NULL END) AS gcsmotor
            , MIN(CASE
                WHEN nursingchartcelltypevallabel = 'Glasgow coma score'
                    AND nursingchartcelltypevalname = 'Verbal'
                    AND REGEXP_CONTAINS(nursingchartvalue, '^[-]?[0-9]+[.]?[0-9]*$')
                    AND nursingchartvalue NOT IN ('-','.')
                    THEN CAST(nursingchartvalue AS NUMERIC)
                ELSE NULL END) AS gcsverbal
            , MIN(CASE
                WHEN nursingchartcelltypevallabel = 'Glasgow coma score'
                    AND nursingchartcelltypevalname = 'Eyes'
                    AND REGEXP_CONTAINS(nursingchartvalue, '^[-]?[0-9]+[.]?[0-9]*$')
                    AND nursingchartvalue NOT IN ('-','.')
                    THEN CAST(nursingchartvalue AS NUMERIC)
                ELSE NULL END) AS gcseyes
        FROM eicu_crd.nursecharting
        WHERE nursingchartcelltypecat IN ('Scores', 'Other Vital Signs and Infusions')
        GROUP BY patientunitstayid, nursingchartoffset
    ) AS nc
JOIN
    (
        SELECT patientid
        FROM csv_table
    ) AS patient_ids ON nc.patientunitstayid = patient_ids.patientid
WHERE
    nc.gcs IS NOT NULL
    OR nc.gcsmotor IS NOT NULL
    OR nc.gcsverbal IS NOT NULL
    OR nc.gcseyes IS NOT NULL;

COPY pivoted_gcs TO '/home/hwxu/Projects/Dataset/PKU/eICU/csv/pivoted_gcs.csv' WITH CSV HEADER;
