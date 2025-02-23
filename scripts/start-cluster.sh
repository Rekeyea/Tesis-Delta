SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_ROOT"
echo "Current directory: $(pwd)"
echo "Looking for docker-compose.yml in: $PROJECT_ROOT"

# Check if docker-compose.yml exists
if [ ! -f "docker-compose.yml" ]; then
    echo "Error: docker-compose.yml not found in $PROJECT_ROOT"
    exit 1
fi

sudo sysctl -w vm.max_map_count=2000000
docker compose up -d
cd ./scripts
./topics.sh
echo "Waiting for Doris ..."
sleep 20
./create-doris-user.sh
# ./flink-session.sh