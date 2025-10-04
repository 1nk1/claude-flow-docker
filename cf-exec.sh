#!/bin/bash
# Execute commands in Claude-Flow container

set -e

CONTAINER_NAME="claude-flow-alpha"

# Проверка что контейнер запущен
if ! docker ps | grep -q $CONTAINER_NAME; then
    echo "❌ Container $CONTAINER_NAME is not running"
    echo "   Start it with: ./cf-start.sh"
    exit 1
fi

# Если команды не переданы, показываем помощь
if [ $# -eq 0 ]; then
    echo "📋 Claude-Flow Command Executor"
    echo ""
    echo "Usage: ./cf-exec.sh [command] [args...]"
    echo ""
    echo "Examples:"
    echo "  ./cf-exec.sh claude-flow --help"
    echo "  ./cf-exec.sh claude-flow hive-mind status"
    echo "  ./cf-exec.sh claude-flow swarm \"build REST API\""
    echo "  ./cf-exec.sh claude-flow memory stats"
    echo "  ./cf-exec.sh npm install lodash"
    echo ""
    exit 0
fi

# Выполнение команды в контейнере
echo "🔧 Executing in container: $@"
echo "======================================"
docker exec -it $CONTAINER_NAME sh -c "cd /workspace/project && $@"
