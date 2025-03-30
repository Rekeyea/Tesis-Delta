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

CREATE DATABASE paimon.delta;

CREATE TABLE paimon.delta.raw_measurements (
    measurement_timestamp TIMESTAMP(3),
    measurement_type STRING,
    raw_value STRING,
    device_id STRING,
    battery DOUBLE,
    signal_strength DOUBLE,
    ingestion_timestamp TIMESTAMP(3),
    WATERMARK FOR measurement_timestamp AS measurement_timestamp - INTERVAL '10' SECONDS
);

CREATE TABLE paimon.delta.enriched_measurements (
    measurement_type STRING,
    `value` DOUBLE,
    device_id STRING,
    patient_id STRING,
    
    -- Weights
    quality_weight DOUBLE,
    freshness_weight DOUBLE,
    
    -- Timestamps
    measurement_timestamp TIMESTAMP(3),
    ingestion_timestamp TIMESTAMP(3),
    enrichment_timestamp TIMESTAMP(3),
    WATERMARK FOR measurement_timestamp AS measurement_timestamp - INTERVAL '10' SECONDS
);

CREATE TABLE paimon.delta.measurements_respiratory_rate (
    device_id STRING,
    patient_id STRING,
    `value` DOUBLE,

    -- Weights
    quality_weight DOUBLE,
    freshness_weight DOUBLE,
    
    -- Timestamps
    measurement_timestamp TIMESTAMP(3),
    ingestion_timestamp TIMESTAMP(3),
    enrichment_timestamp TIMESTAMP(3),
    routing_timestamp TIMESTAMP(3),
    WATERMARK FOR measurement_timestamp AS measurement_timestamp - INTERVAL '10' SECONDS
);

CREATE TABLE paimon.delta.measurements_oxygen_saturation (
    device_id STRING,
    patient_id STRING,
    `value` DOUBLE,

    -- Weights
    quality_weight DOUBLE,
    freshness_weight DOUBLE,
    
    -- Timestamps
    measurement_timestamp TIMESTAMP(3),
    ingestion_timestamp TIMESTAMP(3),
    enrichment_timestamp TIMESTAMP(3),
    routing_timestamp TIMESTAMP(3),
    WATERMARK FOR measurement_timestamp AS measurement_timestamp - INTERVAL '10' SECONDS
);

CREATE TABLE paimon.delta.measurements_blood_pressure_systolic (
    device_id STRING,
    patient_id STRING,
    `value` DOUBLE,

    -- Weights
    quality_weight DOUBLE,
    freshness_weight DOUBLE,
    
    -- Timestamps
    measurement_timestamp TIMESTAMP(3),
    ingestion_timestamp TIMESTAMP(3),
    enrichment_timestamp TIMESTAMP(3),
    routing_timestamp TIMESTAMP(3),
    WATERMARK FOR measurement_timestamp AS measurement_timestamp - INTERVAL '10' SECONDS
);

CREATE TABLE paimon.delta.measurements_heart_rate (
    device_id STRING,
    patient_id STRING,
    `value` DOUBLE,

    -- Weights
    quality_weight DOUBLE,
    freshness_weight DOUBLE,
    
    -- Timestamps
    measurement_timestamp TIMESTAMP(3),
    ingestion_timestamp TIMESTAMP(3),
    enrichment_timestamp TIMESTAMP(3),
    routing_timestamp TIMESTAMP(3),
    WATERMARK FOR measurement_timestamp AS measurement_timestamp - INTERVAL '10' SECONDS
);

CREATE TABLE paimon.delta.measurements_temperature (
    device_id STRING,
    patient_id STRING,
    `value` DOUBLE,

    -- Weights
    quality_weight DOUBLE,
    freshness_weight DOUBLE,
    
    -- Timestamps
    measurement_timestamp TIMESTAMP(3),
    ingestion_timestamp TIMESTAMP(3),
    enrichment_timestamp TIMESTAMP(3),
    routing_timestamp TIMESTAMP(3),
    WATERMARK FOR measurement_timestamp AS measurement_timestamp - INTERVAL '10' SECONDS
);

CREATE TABLE paimon.delta.measurements_consciousness (
    device_id STRING,
    patient_id STRING,
    `value` DOUBLE,

    -- Weights
    quality_weight DOUBLE,
    freshness_weight DOUBLE,
    
    -- Timestamps
    measurement_timestamp TIMESTAMP(3),
    ingestion_timestamp TIMESTAMP(3),
    enrichment_timestamp TIMESTAMP(3),
    routing_timestamp TIMESTAMP(3),
    WATERMARK FOR measurement_timestamp AS measurement_timestamp - INTERVAL '10' SECONDS
);

-- Create tables for measurement scores
CREATE TABLE paimon.delta.scores_respiratory_rate (
    patient_id STRING,
    `value` DOUBLE,
    
    -- Weights
    quality_weight DOUBLE,
    freshness_weight DOUBLE,

    -- Scores
    score INT,
    
    -- Timestamps
    measurement_timestamp TIMESTAMP(3),
    ingestion_timestamp TIMESTAMP(3),
    enrichment_timestamp TIMESTAMP(3),
    routing_timestamp TIMESTAMP(3),
    scoring_timestamp TIMESTAMP(3),
    WATERMARK FOR measurement_timestamp AS measurement_timestamp - INTERVAL '10' SECONDS
);

CREATE TABLE paimon.delta.scores_oxygen_saturation (
    patient_id STRING,
    `value` DOUBLE,
    
    -- Weights
    quality_weight DOUBLE,
    freshness_weight DOUBLE,

    -- Scores
    score INT,
    
    -- Timestamps
    measurement_timestamp TIMESTAMP(3),
    ingestion_timestamp TIMESTAMP(3),
    enrichment_timestamp TIMESTAMP(3),
    routing_timestamp TIMESTAMP(3),
    scoring_timestamp TIMESTAMP(3),
    WATERMARK FOR measurement_timestamp AS measurement_timestamp - INTERVAL '10' SECONDS
);

CREATE TABLE paimon.delta.scores_blood_pressure_systolic (
    patient_id STRING,
    `value` DOUBLE,
    
    -- Weights
    quality_weight DOUBLE,
    freshness_weight DOUBLE,

    -- Scores
    score INT,
    
    -- Timestamps
    measurement_timestamp TIMESTAMP(3),
    ingestion_timestamp TIMESTAMP(3),
    enrichment_timestamp TIMESTAMP(3),
    routing_timestamp TIMESTAMP(3),
    scoring_timestamp TIMESTAMP(3),
    WATERMARK FOR measurement_timestamp AS measurement_timestamp - INTERVAL '10' SECONDS
);

CREATE TABLE paimon.delta.scores_heart_rate (
    patient_id STRING,
    `value` DOUBLE,
    
    -- Weights
    quality_weight DOUBLE,
    freshness_weight DOUBLE,

    -- Scores
    score INT,
    
    -- Timestamps
    measurement_timestamp TIMESTAMP(3),
    ingestion_timestamp TIMESTAMP(3),
    enrichment_timestamp TIMESTAMP(3),
    routing_timestamp TIMESTAMP(3),
    scoring_timestamp TIMESTAMP(3),
    WATERMARK FOR measurement_timestamp AS measurement_timestamp - INTERVAL '10' SECONDS
);

CREATE TABLE paimon.delta.scores_temperature (
    patient_id STRING,
    `value` DOUBLE,
    
    -- Weights
    quality_weight DOUBLE,
    freshness_weight DOUBLE,

    -- Scores
    score INT,
    
    -- Timestamps
    measurement_timestamp TIMESTAMP(3),
    ingestion_timestamp TIMESTAMP(3),
    enrichment_timestamp TIMESTAMP(3),
    routing_timestamp TIMESTAMP(3),
    scoring_timestamp TIMESTAMP(3),
    WATERMARK FOR measurement_timestamp AS measurement_timestamp - INTERVAL '10' SECONDS
);

CREATE TABLE paimon.delta.scores_consciousness (
    patient_id STRING,
    `value` DOUBLE,
    
    -- Weights
    quality_weight DOUBLE,
    freshness_weight DOUBLE,

    -- Scores
    score INT,
    
    -- Timestamps
    measurement_timestamp TIMESTAMP(3),
    ingestion_timestamp TIMESTAMP(3),
    enrichment_timestamp TIMESTAMP(3),
    routing_timestamp TIMESTAMP(3),
    scoring_timestamp TIMESTAMP(3),
    WATERMARK FOR measurement_timestamp AS measurement_timestamp - INTERVAL '10' SECONDS
);


CREATE TABLE paimon.delta.scores (
    patient_id STRING,
    window_start TIMESTAMP(3),
    window_end TIMESTAMP(3),

    respiratory_rate_value DOUBLE,
    oxygen_saturation_value DOUBLE,
    blood_pressure_value DOUBLE,
    heart_rate_value DOUBLE,
    temperature_value DOUBLE,
    consciousness_value DOUBLE,

    respiratory_rate_score DOUBLE,
    oxygen_saturation_score DOUBLE,
    blood_pressure_score DOUBLE,
    heart_rate_score DOUBLE,
    temperature_score DOUBLE,
    consciousness_score DOUBLE,

    respiratory_rate_trust_score DOUBLE,
    oxygen_saturation_trust_score DOUBLE,
    blood_pressure_trust_score DOUBLE,
    heart_rate_trust_score DOUBLE,
    temperature_trust_score DOUBLE,
    consciousness_trust_score DOUBLE,

    measurement_timestamp TIMESTAMP(3),
    ingestion_timestamp TIMESTAMP(3),
    enrichment_timestamp TIMESTAMP(3),
    routing_timestamp TIMESTAMP(3),
    scoring_timestamp TIMESTAMP(3),
    union_timestamp TIMESTAMP(3),
    WATERMARK FOR measurement_timestamp AS measurement_timestamp - INTERVAL '10' SECONDS,
    PRIMARY KEY (patient_id, window_start) NOT ENFORCED
);

CREATE TABLE paimon.delta.gdnews2_scores (
    patient_id STRING,
    window_start TIMESTAMP(3),
    window_end TIMESTAMP(3),

    -- AVG Raw measurements
    respiratory_rate_value DOUBLE,
    oxygen_saturation_value DOUBLE,
    blood_pressure_value DOUBLE,
    heart_rate_value DOUBLE,
    temperature_value DOUBLE,
    consciousness_value DOUBLE,

    -- Raw NEWS2 scores
    respiratory_rate_score DOUBLE,
    oxygen_saturation_score DOUBLE,
    blood_pressure_score DOUBLE,
    heart_rate_score DOUBLE,
    temperature_score DOUBLE,
    consciousness_score DOUBLE,
    news2_score DOUBLE,

    -- Trust gdNEWS2 scores
    respiratory_rate_trust_score DOUBLE,
    oxygen_saturation_trust_score DOUBLE,
    blood_pressure_trust_score DOUBLE,
    heart_rate_trust_score DOUBLE,
    temperature_trust_score DOUBLE,
    consciousness_trust_score DOUBLE,

    news2_trust_score DOUBLE,

    -- Timestamps
    measurement_timestamp TIMESTAMP(3),
    ingestion_timestamp TIMESTAMP(3),
    enrichment_timestamp TIMESTAMP(3),
    routing_timestamp TIMESTAMP(3),
    scoring_timestamp TIMESTAMP(3),
    union_timestamp TIMESTAMP(3),
    aggregation_timestamp TIMESTAMP(3),
    WATERMARK FOR measurement_timestamp AS measurement_timestamp - INTERVAL '10' SECONDS,
    PRIMARY KEY (patient_id, window_start) NOT ENFORCED
);