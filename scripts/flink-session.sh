# docker exec -it jobmanager /opt/flink/bin/sql-client.sh -f /opt/flink/bin/jobs/job.sql

docker exec -it jobmanager /opt/flink/bin/sql-client.sh -f /opt/flink/bin/jobs/tables.sql
docker exec -it jobmanager /opt/flink/bin/sql-client.sh -f /opt/flink/bin/jobs/ingestion.sql
docker exec -it jobmanager /opt/flink/bin/sql-client.sh -f /opt/flink/bin/jobs/enrichment.sql
docker exec -it jobmanager /opt/flink/bin/sql-client.sh -f /opt/flink/bin/jobs/transform.sql
docker exec -it jobmanager /opt/flink/bin/sql-client.sh -f /opt/flink/bin/jobs/aggregate.sql