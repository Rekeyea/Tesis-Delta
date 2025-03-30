SET 'execution.runtime-mode' = 'streaming';
SET 'execution.checkpointing.mode' = 'EXACTLY_ONCE';
SET 'table.local-time-zone' = 'UTC';
SET 'execution.checkpointing.interval' = '60000';
SET 'execution.checkpointing.timeout' = '30000';
SET 'state.backend' = 'hashmap';
SET 'table.exec.state.ttl' = '300000';
SET 'parallelism.default' = '2';


CREATE CATALOG paimon WITH (
    'type' = 'paimon',
    'warehouse' = 's3://datalake/paimon',
    's3.endpoint' = 'http://minio:9000',
    's3.access-key' = 'minioadmin',  
    's3.secret-key' = 'minioadmin',
    's3.path.style.access' = 'true',
    'location-in-properties' = 'true'
);


-- Respiratory Rate Scoring
INSERT INTO paimon.delta.scores_respiratory_rate
SELECT
    patient_id,
    `value`,
    quality_weight,
    freshness_weight,

    CASE
        WHEN `value` <= 8 THEN 3
        WHEN `value` >= 25 THEN 3
        WHEN `value` BETWEEN 21 AND 24 THEN 2
        WHEN `value` BETWEEN 9 AND 11 THEN 1
        WHEN `value` BETWEEN 12 AND 20 THEN 0
    END AS respiratory_rate_score,
    
    measurement_timestamp,
    ingestion_timestamp,
    enrichment_timestamp,
    routing_timestamp,
    CURRENT_TIMESTAMP as scoring_timestamp
FROM paimon.delta.measurements_respiratory_rate;

-- Oxygen Saturation Scoring
INSERT INTO paimon.delta.scores_oxygen_saturation
SELECT
    patient_id,
    `value`,
    quality_weight,
    freshness_weight,
    CAST(CASE
        WHEN `value` <= 91 THEN 3
        WHEN `value` BETWEEN 92 AND 93 THEN 2
        WHEN `value` BETWEEN 94 AND 95 THEN 1
        WHEN `value` >= 96 THEN 0
    END AS INT) AS score,
    
    measurement_timestamp,
    ingestion_timestamp,
    enrichment_timestamp,
    routing_timestamp,
    CURRENT_TIMESTAMP as scoring_timestamp
FROM paimon.delta.measurements_oxygen_saturation;

-- Blood Pressure Scoring
INSERT INTO paimon.delta.scores_blood_pressure_systolic
SELECT
    patient_id,
    `value`,
    quality_weight,
    freshness_weight,
    CAST(CASE
        WHEN `value` <= 90 THEN 3
        WHEN `value` <= 100 THEN 2
        WHEN `value` <= 110 THEN 1
        WHEN `value` BETWEEN 111 AND 219 THEN 0
        WHEN `value` >= 220 THEN 3
    END AS INT) AS score,
    
    measurement_timestamp,
    ingestion_timestamp,
    enrichment_timestamp,
    routing_timestamp,
    CURRENT_TIMESTAMP as scoring_timestamp
FROM paimon.delta.measurements_blood_pressure_systolic;

-- Heart Rate Scoring
INSERT INTO paimon.delta.scores_heart_rate
SELECT
    patient_id,
    `value`,
    quality_weight,
    freshness_weight,
    CAST(CASE
        WHEN `value` <= 40 THEN 3
        WHEN `value` >= 131 THEN 3
        WHEN `value` BETWEEN 111 AND 130 THEN 2
        WHEN `value` BETWEEN 41 AND 50 THEN 1
        WHEN `value` BETWEEN 91 AND 110 THEN 1
        WHEN `value` BETWEEN 51 AND 90 THEN 0
    END AS INT) AS score,
    
    measurement_timestamp,
    ingestion_timestamp,
    enrichment_timestamp,
    routing_timestamp,
    CURRENT_TIMESTAMP as scoring_timestamp
FROM paimon.delta.measurements_heart_rate;

-- Temperature Scoring
INSERT INTO paimon.delta.scores_temperature
SELECT
    patient_id,
    `value`,
    quality_weight,
    freshness_weight,
    CAST(CASE
        WHEN `value` <= 35.0 THEN 3
        WHEN `value` >= 39.1 THEN 2
        WHEN `value` BETWEEN 38.1 AND 39.0 THEN 1
        WHEN `value` BETWEEN 35.1 AND 36.0 THEN 1
        WHEN `value` BETWEEN 36.1 AND 38.0 THEN 0
    END AS INT) AS score,
    
    measurement_timestamp,
    ingestion_timestamp,
    enrichment_timestamp,
    routing_timestamp,
    CURRENT_TIMESTAMP as scoring_timestamp
FROM paimon.delta.measurements_temperature;

-- Consciousness Scoring
INSERT INTO paimon.delta.scores_consciousness
SELECT
    patient_id,
    `value`,
    quality_weight,
    freshness_weight,
    CAST(CASE
        WHEN `value` = 1 THEN 0
        ELSE 3
    END AS INT) AS score,
    
    measurement_timestamp,
    ingestion_timestamp,
    enrichment_timestamp,
    routing_timestamp,
    CURRENT_TIMESTAMP as scoring_timestamp
FROM paimon.delta.measurements_consciousness;