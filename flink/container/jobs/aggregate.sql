SET 'execution.runtime-mode' = 'streaming';
SET 'execution.checkpointing.interval' = '1 s';
SET 'execution.checkpointing.mode' = 'EXACTLY_ONCE';
SET 'execution.checkpointing.timeout' = '120s';
SET 'execution.checkpointing.min-pause' = '5s';
SET 'execution.checkpointing.max-concurrent-checkpoints' = '1';
SET 'table.local-time-zone' = 'UTC';
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

USE CATALOG paimon;
USE delta;

INSERT INTO paimon.delta.gdnews2_scores /*+ OPTIONS('parallelism'='6') */
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
    respiratory_rate_score +
    oxygen_saturation_score +
    blood_pressure_score +
    heart_rate_score +
    temperature_score +
    consciousness_score AS news2_score,

    -- Statuses
    CAST(CASE 
        WHEN 0.7 * respiratory_rate_quality_weight + 0.3 *respiratory_rate_freshness_weight > 0.75 THEN 'VALID'
        WHEN 0.7 * respiratory_rate_quality_weight + 0.3 *respiratory_rate_freshness_weight > 0.5 THEN 'DEGRADED'
        ELSE 'INVALID'
    END 
    AS STRING) as respiratory_rate_status,
    CAST(CASE 
        WHEN 0.7 * oxygen_saturation_quality_weight + 0.3 *oxygen_saturation_freshness_weight > 0.75 THEN 'VALID'
        WHEN 0.7 * oxygen_saturation_quality_weight + 0.3 *oxygen_saturation_freshness_weight > 0.5 THEN 'DEGRADED'
        ELSE 'INVALID'
    END
    AS STRING) as oxygen_saturation_status,
    CAST(CASE 
        WHEN 0.7 * blood_pressure_quality_weight + 0.3 *blood_pressure_freshness_weight > 0.75 THEN 'VALID'
        WHEN 0.7 * blood_pressure_quality_weight + 0.3 *blood_pressure_freshness_weight > 0.5 THEN 'DEGRADED'
        ELSE 'INVALID'
    END
    AS STRING) as blood_pressure_status,
    CAST(CASE 
        WHEN 0.7 * heart_rate_quality_weight + 0.3 *heart_rate_freshness_weight > 0.75 THEN 'VALID'
        WHEN 0.7 * heart_rate_quality_weight + 0.3 *heart_rate_freshness_weight > 0.5 THEN 'DEGRADED'
        ELSE 'INVALID'
    END
    AS STRING) as heart_rate_status,
    CAST(CASE 
        WHEN 0.7 * temperature_quality_weight + 0.3 *temperature_freshness_weight > 0.75 THEN 'VALID'
        WHEN 0.7 * temperature_quality_weight + 0.3 *temperature_freshness_weight > 0.5 THEN 'DEGRADED'
        ELSE 'INVALID'
    END
    AS STRING) as temperature_status,
    CAST(CASE 
        WHEN 0.7 * consciousness_quality_weight + 0.3 *consciousness_freshness_weight > 0.75 THEN 'VALID'
        WHEN 0.7 * consciousness_quality_weight + 0.3 *consciousness_freshness_weight > 0.5 THEN 'DEGRADED'
        ELSE 'INVALID'
    END
    AS STRING) as consciousness_status,

    -- adjusted scores
    0.7 * respiratory_rate_quality_weight + 0.3 *respiratory_rate_freshness_weight AS respiratory_rate_trust_score,
    0.7 * oxygen_saturation_quality_weight + 0.3 *oxygen_saturation_freshness_weight AS oxygen_saturation_trust_score,
    0.7 * blood_pressure_quality_weight + 0.3 *blood_pressure_freshness_weight AS blood_pressure_trust_score,
    0.7 * heart_rate_quality_weight + 0.3 *heart_rate_freshness_weight AS heart_rate_trust_score,
    0.7 * temperature_quality_weight + 0.3 *temperature_freshness_weight AS temperature_trust_score,
    0.7 * consciousness_quality_weight + 0.3 *consciousness_freshness_weight AS consciousness_trust_score,

    (
        0.7 * respiratory_rate_quality_weight + 0.3 *respiratory_rate_freshness_weight +
        0.7 * oxygen_saturation_quality_weight + 0.3 *oxygen_saturation_freshness_weight +
        0.7 * blood_pressure_quality_weight + 0.3 *blood_pressure_freshness_weight +
        0.7 * heart_rate_quality_weight + 0.3 *heart_rate_freshness_weight +
        0.7 * temperature_quality_weight + 0.3 *temperature_freshness_weight +
        0.7 * consciousness_quality_weight + 0.3 *consciousness_freshness_weight
    ) / 6 AS news2_trust_score,
    
    -- use aggregated timestamps (make sure these come after the parameters)
    measurement_timestamp,
    ingestion_timestamp,
    enrichment_timestamp,
    routing_timestamp,
    scoring_timestamp,
    CURRENT_TIMESTAMP AS flink_timestamp,
    CURRENT_TIMESTAMP AS aggregation_timestamp
FROM (
    WITH scores AS (
        SELECT 
            `value` as rr_value, CAST(NULL AS INT) as os_value, CAST(NULL AS INT) as bp_value, CAST(NULL AS INT) as hr_value, CAST(NULL AS INT) as tp_value, CAST(NULL AS INT) as cs_value,
            score as rr_score, CAST(NULL AS INT) as os_score, CAST(NULL AS INT) as bp_score, CAST(NULL AS INT) as hr_score, CAST(NULL AS INT) as tp_score, CAST(NULL AS INT) as cs_score,
            quality_weight as rr_quality_weight, CAST(NULL AS INT) as os_quality_weight, CAST(NULL AS INT) as bp_quality_weight, CAST(NULL AS INT) as hr_quality_weight, CAST(NULL AS INT) as tp_quality_weight, CAST(NULL AS INT) as cs_quality_weight,
            freshness_weight as rr_freshness_weight, CAST(NULL AS INT) as os_freshness_weight, CAST(NULL AS INT) as bp_freshness_weight, CAST(NULL AS INT) as hr_freshness_weight, CAST(NULL AS INT) as tp_freshness_weight, CAST(NULL AS INT) as cs_freshness_weight,
            patient_id, measurement_timestamp, ingestion_timestamp, enrichment_timestamp, routing_timestamp, scoring_timestamp
        FROM paimon.delta.scores_respiratory_rate
        UNION ALL
        SELECT 
            CAST(NULL AS INT) as rr_value, `value` as os_value, CAST(NULL AS INT) as bp_value, CAST(NULL AS INT) as hr_value, CAST(NULL AS INT) as tp_value, CAST(NULL AS INT) as cs_value,
            CAST(NULL AS INT) as rr_score, score as os_score, CAST(NULL AS INT) as bp_score, CAST(NULL AS INT) as hr_score, CAST(NULL AS INT) as tp_score, CAST(NULL AS INT) as cs_score,
            CAST(NULL AS INT) as rr_quality_weight, quality_weight as os_quality_weight, CAST(NULL AS INT) as bp_quality_weight, CAST(NULL AS INT) as hr_quality_weight, CAST(NULL AS INT) as tp_quality_weight, CAST(NULL AS INT) as cs_quality_weight,
            CAST(NULL AS INT) as rr_freshness_weight, freshness_weight as os_freshness_weight, CAST(NULL AS INT) as bp_freshness_weight, CAST(NULL AS INT) as hr_freshness_weight, CAST(NULL AS INT) as tp_freshness_weight, CAST(NULL AS INT) as cs_freshness_weight,
            patient_id, measurement_timestamp, ingestion_timestamp, enrichment_timestamp, routing_timestamp , scoring_timestamp
        FROM paimon.delta.scores_oxygen_saturation
        UNION ALL
        SELECT 
            CAST(NULL AS INT) as rr_value, CAST(NULL AS INT) as os_value, `value` as bp_value, CAST(NULL AS INT) as hr_value, CAST(NULL AS INT) as tp_value, CAST(NULL AS INT) as cs_value,
            CAST(NULL AS INT) as rr_score, CAST(NULL AS INT) as os_score, score as bp_score, CAST(NULL AS INT) as hr_score, CAST(NULL AS INT) as tp_score, CAST(NULL AS INT) as cs_score,
            CAST(NULL AS INT) as rr_quality_weight, CAST(NULL AS INT) as os_quality_weight, quality_weight as bp_quality_weight, CAST(NULL AS INT) as hr_quality_weight, CAST(NULL AS INT) as tp_quality_weight, CAST(NULL AS INT) as cs_quality_weight,
            CAST(NULL AS INT) as rr_freshness_weight, CAST(NULL AS INT) as os_freshness_weight, freshness_weight as bp_freshness_weight, CAST(NULL AS INT) as hr_freshness_weight, CAST(NULL AS INT) as tp_freshness_weight, CAST(NULL AS INT) as cs_freshness_weight,
            patient_id, measurement_timestamp, ingestion_timestamp, enrichment_timestamp, routing_timestamp , scoring_timestamp
        FROM paimon.delta.scores_blood_pressure_systolic
        UNION ALL
        SELECT
            CAST(NULL AS INT) as rr_value, CAST(NULL AS INT) as os_value, CAST(NULL AS INT) as bp_value, `value` as hr_value, CAST(NULL AS INT) as tp_value, CAST(NULL AS INT) as cs_value,
            CAST(NULL AS INT) as rr_score, CAST(NULL AS INT) as os_score, CAST(NULL AS INT) as bp_score, score as hr_score, CAST(NULL AS INT) as tp_score, CAST(NULL AS INT) as cs_score,
            CAST(NULL AS INT) as rr_quality_weight, CAST(NULL AS INT) as os_quality_weight, CAST(NULL AS INT) as bp_quality_weight, quality_weight as hr_quality_weight, CAST(NULL AS INT) as tp_quality_weight, CAST(NULL AS INT) as cs_quality_weight,
            CAST(NULL AS INT) as rr_freshness_weight, CAST(NULL AS INT) as os_freshness_weight, CAST(NULL AS INT) as bp_freshness_weight, freshness_weight as hr_freshness_weight, CAST(NULL AS INT) as tp_freshness_weight, CAST(NULL AS INT) as cs_freshness_weight,
            patient_id, measurement_timestamp, ingestion_timestamp, enrichment_timestamp, routing_timestamp , scoring_timestamp
        FROM paimon.delta.scores_heart_rate
        UNION ALL
        SELECT 
            CAST(NULL AS INT) as rr_value, CAST(NULL AS INT) as os_value, CAST(NULL AS INT) as bp_value, CAST(NULL AS INT) as hr_value, `value` as tp_value, CAST(NULL AS INT) as cs_value,
            CAST(NULL AS INT) as rr_score, CAST(NULL AS INT) as os_score, CAST(NULL AS INT) as bp_score, CAST(NULL AS INT) as hr_score, score as tp_score, CAST(NULL AS INT) as cs_score,
            CAST(NULL AS INT) as rr_quality_weight, CAST(NULL AS INT) as os_quality_weight, CAST(NULL AS INT) as bp_quality_weight, CAST(NULL AS INT) as hr_quality_weight, quality_weight as tp_quality_weight, CAST(NULL AS INT) as cs_quality_weight,
            CAST(NULL AS INT) as rr_freshness_weight, CAST(NULL AS INT) as os_freshness_weight, CAST(NULL AS INT) as bp_freshness_weight, CAST(NULL AS INT) as hr_freshness_weight, freshness_weight as tp_freshness_weight, CAST(NULL AS INT) as cs_freshness_weight,
            patient_id, measurement_timestamp, ingestion_timestamp, enrichment_timestamp, routing_timestamp , scoring_timestamp
        FROM paimon.delta.scores_temperature
        UNION ALL
        SELECT 
            CAST(NULL AS INT) as rr_value, CAST(NULL AS INT) as os_value, CAST(NULL AS INT) as bp_value, CAST(NULL AS INT) as hr_value, CAST(NULL AS INT) as tp_value, `value` as cs_value,
            CAST(NULL AS INT) as rr_score, CAST(NULL AS INT) as os_score, CAST(NULL AS INT) as bp_score, CAST(NULL AS INT) as hr_score, CAST(NULL AS INT) as tp_score, score as cs_score,
            CAST(NULL AS INT) as rr_quality_weight, CAST(NULL AS INT) as os_quality_weight, CAST(NULL AS INT) as bp_quality_weight, CAST(NULL AS INT) as hr_quality_weight, CAST(NULL AS INT) as tp_quality_weight, quality_weight as cs_quality_weight,
            CAST(NULL AS INT) as rr_freshness_weight, CAST(NULL AS INT) as os_freshness_weight, CAST(NULL AS INT) as bp_freshness_weight, CAST(NULL AS INT) as hr_freshness_weight, CAST(NULL AS INT) as tp_freshness_weight, freshness_weight as cs_freshness_weight,
            patient_id, measurement_timestamp, ingestion_timestamp, enrichment_timestamp, routing_timestamp , scoring_timestamp
        FROM paimon.delta.scores_consciousness
    )
    SELECT
        patient_id,
        window_start,
        MAX(window_end) as window_end,
        COALESCE(AVG(rr_value), 0) AS respiratory_rate_value,
        COALESCE(AVG(os_value), 0) AS oxygen_saturation_value,
        COALESCE(AVG(bp_value), 0) AS blood_pressure_value,
        COALESCE(AVG(hr_value), 0) AS heart_rate_value,
        COALESCE(AVG(tp_value), 0) AS temperature_value,
        COALESCE(AVG(cs_value), 0) AS consciousness_value,

        COALESCE(AVG(rr_score), 0) AS respiratory_rate_score,
        COALESCE(AVG(os_score), 0) AS oxygen_saturation_score,
        COALESCE(AVG(bp_score), 0) AS blood_pressure_score,
        COALESCE(AVG(hr_score), 0) AS heart_rate_score,
        COALESCE(AVG(tp_score), 0) AS temperature_score,
        COALESCE(AVG(cs_score), 0) AS consciousness_score, 

        COALESCE(AVG(rr_quality_weight), 0.2) AS respiratory_rate_quality_weight,
        COALESCE(AVG(os_quality_weight), 0.2) AS oxygen_saturation_quality_weight,
        COALESCE(AVG(bp_quality_weight), 0.2) AS blood_pressure_quality_weight,
        COALESCE(AVG(hr_quality_weight), 0.2) AS heart_rate_quality_weight,
        COALESCE(AVG(tp_quality_weight), 0.2) AS temperature_quality_weight,
        COALESCE(AVG(cs_quality_weight), 0.2) AS consciousness_quality_weight,


        COALESCE(AVG(rr_freshness_weight), 0.2) AS respiratory_rate_freshness_weight,
        COALESCE(AVG(os_freshness_weight), 0.2) AS oxygen_saturation_freshness_weight,
        COALESCE(AVG(bp_freshness_weight), 0.2) AS blood_pressure_freshness_weight,
        COALESCE(AVG(hr_freshness_weight), 0.2) AS heart_rate_freshness_weight,
        COALESCE(AVG(tp_freshness_weight), 0.2) AS temperature_freshness_weight,
        COALESCE(AVG(cs_freshness_weight), 0.2) AS consciousness_freshness_weight,

        MIN(measurement_timestamp) AS measurement_timestamp,
        MIN(ingestion_timestamp) AS ingestion_timestamp,
        MIN(enrichment_timestamp) AS enrichment_timestamp,
        MIN(routing_timestamp) AS routing_timestamp,
        MIN(scoring_timestamp) AS scoring_timestamp
    FROM TABLE(
        TUMBLE(
            TABLE scores, 
            DESCRIPTOR(measurement_timestamp), 
            INTERVAL '1' MINUTES
        )
    ) AS gdnews2
    GROUP BY patient_id, window_start
) AS gdnews2;