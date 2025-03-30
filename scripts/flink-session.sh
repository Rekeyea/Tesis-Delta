# docker exec -it jobmanager /opt/flink/bin/sql-client.sh -f /opt/flink/bin/jobs/job.sql

docker exec -it jobmanager /opt/flink/bin/sql-client.sh -f /opt/flink/bin/jobs/tables.sql
docker exec -it jobmanager /opt/flink/bin/sql-client.sh -f /opt/flink/bin/jobs/ingestion.sql
docker exec -it jobmanager /opt/flink/bin/sql-client.sh -f /opt/flink/bin/jobs/enrichment.sql
docker exec -it jobmanager /opt/flink/bin/sql-client.sh -f /opt/flink/bin/jobs/routing.sql
docker exec -it jobmanager /opt/flink/bin/sql-client.sh -f /opt/flink/bin/jobs/scoring.sql
docker exec -it jobmanager /opt/flink/bin/sql-client.sh -f /opt/flink/bin/jobs/union.sql
docker exec -it jobmanager /opt/flink/bin/sql-client.sh -f /opt/flink/bin/jobs/aggregate.sql