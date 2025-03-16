#!/bin/bash

# Create user and grant privileges
# Here we set metadata_refresh_interval_sec so there is no cache but we need to consider its cost trade-off
docker exec -i doris-fe mysql -h 127.0.0.1 -P 9030 -u root << EOF
CREATE CATALOG paimon PROPERTIES (
    "type" = "paimon",
    "warehouse" = "s3://datalake/paimon",
    "s3.endpoint" = "http://172.20.1.2:9000",
    "s3.access_key" = "minioadmin",
    "s3.secret_key" = "minioadmin",
    's3.path.style.access' = 'true',
    'location-in-properties' = 'true',
    'metadata_refresh_interval_sec' = '0'
);

CREATE USER 'delta'@'%' IDENTIFIED BY 'delta';
GRANT ADMIN_PRIV ON *.*.* TO 'delta'@'%';

SET GLOBAL TIME_ZONE = 'UTC';
SET TIME_ZONE = 'UTC';
EOF