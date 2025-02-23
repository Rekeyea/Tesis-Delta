#!/bin/bash

# Wait for Kafka UI to be ready
echo "Waiting for Kafka UI to be up..."
until $(curl --output /dev/null --silent --fail http://localhost:10150/api/clusters); do
    printf '.'
    sleep 5
done

# Function to create a topic
create_topic() {
    local topic_name=$1
    echo "Creating topic: $topic_name"
    curl -X POST http://localhost:10150/api/clusters/local/topics \
      -H 'Content-Type: application/json' \
      -d "{
        \"name\": \"$topic_name\",
        \"partitions\": 3,
        \"replicationFactor\": 3,
        \"configs\": {
          \"retention.ms\": \"604800000\",
          \"cleanup.policy\": \"delete\"
        }
      }"
    echo -e "\n"
}

# Create base topics
create_topic "raw.measurements"

# List all topics
echo "Created topics:"
curl -s http://localhost:10150/api/clusters/local/topics | jq '.topics[].name'