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

-- Insert for respiratory rate measurements
INSERT INTO paimon.delta.measurements_respiratory_rate
SELECT
    device_id,
    patient_id,
    `value`,
    quality_weight,
    freshness_weight,
    measurement_timestamp,
    ingestion_timestamp,
    enrichment_timestamp,
    CURRENT_TIMESTAMP AS routing_timestamp
FROM paimon.delta.enriched_measurements
WHERE measurement_type = 'RESPIRATORY_RATE';

-- Insert for oxygen saturation measurements
INSERT INTO paimon.delta.measurements_oxygen_saturation
SELECT
    device_id,
    patient_id,
    `value`,
    quality_weight,
    freshness_weight,
    measurement_timestamp,
    ingestion_timestamp,
    enrichment_timestamp,
    CURRENT_TIMESTAMP AS routing_timestamp
FROM paimon.delta.enriched_measurements
WHERE measurement_type = 'OXYGEN_SATURATION';

-- Insert for blood pressure measurements
INSERT INTO paimon.delta.measurements_blood_pressure_systolic
SELECT
    device_id,
    patient_id,
    `value`,
    quality_weight,
    freshness_weight,
    measurement_timestamp,
    ingestion_timestamp,
    enrichment_timestamp,
    CURRENT_TIMESTAMP AS routing_timestamp
FROM paimon.delta.enriched_measurements
WHERE measurement_type = 'BLOOD_PRESSURE_SYSTOLIC';

-- Insert for heart rate measurements
INSERT INTO paimon.delta.measurements_heart_rate
SELECT
    device_id,
    patient_id,
    `value`,
    quality_weight,
    freshness_weight,
    measurement_timestamp,
    ingestion_timestamp,
    enrichment_timestamp,
    CURRENT_TIMESTAMP AS routing_timestamp
FROM paimon.delta.enriched_measurements
WHERE measurement_type = 'HEART_RATE';

-- Insert for temperature measurements
INSERT INTO paimon.delta.measurements_temperature
SELECT
    device_id,
    patient_id,
    `value`,
    quality_weight,
    freshness_weight,
    measurement_timestamp,
    ingestion_timestamp,
    enrichment_timestamp,
    CURRENT_TIMESTAMP AS routing_timestamp
FROM paimon.delta.enriched_measurements
WHERE measurement_type = 'TEMPERATURE';

-- Insert for consciousness measurements
INSERT INTO paimon.delta.measurements_consciousness
SELECT
    device_id,
    patient_id,
    `value`,
    quality_weight,
    freshness_weight,
    measurement_timestamp,
    ingestion_timestamp,
    enrichment_timestamp,
    CURRENT_TIMESTAMP AS routing_timestamp
FROM paimon.delta.enriched_measurements
WHERE measurement_type = 'CONSCIOUSNESS';