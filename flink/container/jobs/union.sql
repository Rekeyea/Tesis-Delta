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

INSERT INTO paimon.delta.scores
SELECT * FROM (
    WITH unions as (
        SELECT * FROM
        (
            SELECT 
                'RESPIRATORY_RATE' as measurement_type, patient_id, `value`, score, 0.7 * quality_weight + 0.3 * freshness_weight as trust_score, 
                measurement_timestamp, ingestion_timestamp, enrichment_timestamp, routing_timestamp, scoring_timestamp
            FROM paimon.delta.scores_respiratory_rate
            UNION ALL
            SELECT 
                'OXYGEN_SATURATION' as measurement_type, patient_id, `value`, score, 0.7 * quality_weight + 0.3 * freshness_weight as trust_score, 
                measurement_timestamp, ingestion_timestamp, enrichment_timestamp, routing_timestamp, scoring_timestamp
            FROM paimon.delta.scores_oxygen_saturation
            UNION ALL
            SELECT 
                'BLOOD_PRESSURE_SYSTOLIC' as measurement_type, patient_id, `value`, score, 0.7 * quality_weight + 0.3 * freshness_weight as trust_score, 
                measurement_timestamp, ingestion_timestamp, enrichment_timestamp, routing_timestamp, scoring_timestamp
            FROM paimon.delta.scores_blood_pressure_systolic
            UNION ALL
            SELECT
                'HEART_RATE' as measurement_type, patient_id, `value`, score, 0.7 * quality_weight + 0.3 * freshness_weight as trust_score, 
                measurement_timestamp, ingestion_timestamp, enrichment_timestamp, routing_timestamp, scoring_timestamp
            FROM paimon.delta.scores_heart_rate
            UNION ALL
            SELECT 
                'TEMPERATURE' as measurement_type, patient_id, `value`, score, 0.7 * quality_weight + 0.3 * freshness_weight as trust_score, 
                measurement_timestamp, ingestion_timestamp, enrichment_timestamp, routing_timestamp, scoring_timestamp
            FROM paimon.delta.scores_temperature
            UNION ALL
            SELECT 
                'CONSCIOUSNESS' as measurement_type, patient_id, `value`, score, 0.7 * quality_weight + 0.3 * freshness_weight as trust_score, 
                measurement_timestamp, ingestion_timestamp, enrichment_timestamp, routing_timestamp, scoring_timestamp
            FROM paimon.delta.scores_consciousness
        ) as unions
    )
    SELECT 
        patient_id,
        window_start,
        MAX(window_end) as window_end,

        MAX(CASE WHEN measurement_type = 'RESPIRATORY_RATE' THEN `value` END) as respiratory_rate_value,
        MAX(CASE WHEN measurement_type = 'OXYGEN_SATURATION' THEN `value` END) as oxygen_saturation_value,
        MAX(CASE WHEN measurement_type = 'BLOOD_PRESSURE_SYSTOLIC' THEN `value` END) as blood_pressure_value,
        MAX(CASE WHEN measurement_type = 'HEART_RATE' THEN `value` END) as heart_rate_value,
        MAX(CASE WHEN measurement_type = 'TEMPERATURE' THEN `value` END) as temperature_value,
        MAX(CASE WHEN measurement_type = 'CONSCIOUSNESS' THEN `value` END) as consciousness_value,

        COALESCE(MAX(CASE WHEN measurement_type = 'RESPIRATORY_RATE' THEN score END), 0) as respiratory_rate_score,
        COALESCE(MAX(CASE WHEN measurement_type = 'OXYGEN_SATURATION' THEN score END), 0) as oxygen_saturation_score,
        COALESCE(MAX(CASE WHEN measurement_type = 'BLOOD_PRESSURE_SYSTOLIC' THEN score END), 0) as blood_pressure_score,
        COALESCE(MAX(CASE WHEN measurement_type = 'HEART_RATE' THEN score END), 0) as heart_rate_score,
        COALESCE(MAX(CASE WHEN measurement_type = 'TEMPERATURE' THEN score END), 0) as temperature_score,
        COALESCE(MAX(CASE WHEN measurement_type = 'CONSCIOUSNESS' THEN score END), 0) as consciousness_score,

        COALESCE(AVG(CASE WHEN measurement_type = 'RESPIRATORY_RATE' THEN trust_score END), 0) as respiratory_rate_trust_score,
        COALESCE(AVG(CASE WHEN measurement_type = 'OXYGEN_SATURATION' THEN trust_score END), 0) as oxygen_saturation_trust_score,
        COALESCE(AVG(CASE WHEN measurement_type = 'BLOOD_PRESSURE_SYSTOLIC' THEN trust_score END), 0) as blood_pressure_trust_score,
        COALESCE(AVG(CASE WHEN measurement_type = 'HEART_RATE' THEN trust_score END), 0) as heart_rate_trust_score,
        COALESCE(AVG(CASE WHEN measurement_type = 'TEMPERATURE' THEN trust_score END), 0) as temperature_trust_score,
        COALESCE(AVG(CASE WHEN measurement_type = 'CONSCIOUSNESS' THEN trust_score END), 0) as consciousness_trust_score,

        MIN(measurement_timestamp) AS measurement_timestamp,
        MIN(ingestion_timestamp) AS ingestion_timestamp,
        MIN(enrichment_timestamp) AS enrichment_timestamp,
        MIN(routing_timestamp) AS routing_timestamp,
        MIN(scoring_timestamp) AS scoring_timestamp,
        CURRENT_TIMESTAMP as union_timestamp
    FROM TABLE(
        TUMBLE(
            TABLE unions, 
            DESCRIPTOR(measurement_timestamp), 
            INTERVAL '1' MINUTES
        )
    ) AS unions 
    GROUP BY patient_id, window_start
) as t;