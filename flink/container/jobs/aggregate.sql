SET 'execution.runtime-mode' = 'streaming';
SET 'execution.checkpointing.mode' = 'EXACTLY_ONCE';
SET 'table.local-time-zone' = 'UTC';
SET 'execution.checkpointing.interval' = '60000';
SET 'execution.checkpointing.timeout' = '30000';
SET 'state.backend' = 'hashmap';
SET 'table.exec.state.ttl' = '300000';
SET 'parallelism.default' = '6';


CREATE CATALOG paimon WITH (
    'type' = 'paimon',
    'warehouse' = 's3://datalake/paimon',
    's3.endpoint' = 'http://minio:9000',
    's3.access-key' = 'minioadmin',  
    's3.secret-key' = 'minioadmin',
    's3.path.style.access' = 'true',
    'location-in-properties' = 'true'
);

INSERT INTO paimon.delta.gdnews2_scores
SELECT
    patient_id,
    window_start,
    window_end,

    respiratory_rate_value,
    oxygen_saturation_value,
    blood_pressure_value,
    heart_rate_value,
    temperature_value,
    consciousness_value,

    respiratory_rate_score,
    oxygen_saturation_score,
    blood_pressure_score,
    heart_rate_score,
    temperature_score,
    consciousness_score,

    -- raw NEWS2 total
    (
        respiratory_rate_score +
        oxygen_saturation_score +
        blood_pressure_score +
        heart_rate_score +
        temperature_score +
        consciousness_score
    ) AS news2_score,

    -- adjusted scores
    respiratory_rate_trust_score,
    oxygen_saturation_trust_score,
    blood_pressure_trust_score,
    heart_rate_trust_score,
    temperature_trust_score,
    consciousness_trust_score,

    (
        respiratory_rate_trust_score +
        oxygen_saturation_trust_score +
        blood_pressure_trust_score +
        heart_rate_trust_score +
        temperature_trust_score +
        consciousness_trust_score
    ) AS news2_trust_score,
    
    -- use aggregated timestamps (make sure these come after the parameters)
    measurement_timestamp,
    ingestion_timestamp,
    enrichment_timestamp,
    routing_timestamp,
    scoring_timestamp,
    union_timestamp,
    CURRENT_TIMESTAMP AS aggregation_timestamp
FROM paimon.delta.scores;