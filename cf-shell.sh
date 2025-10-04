#!/bin/bash
# Interactive shell in Claude-Flow container

CONTAINER_NAME="claude-flow-alpha"

# Проверка что контейнер запущен
if ! docker ps | grep -q $CONTAINER_NAME; then
    echo "❌ Container $CONTAINER_NAME is not running"
    echo "   Start it with: ./cf-start.sh"
    exit 1
fi

echo "🐚 Opening interactive shell in Claude-Flow container..."
echo "======================================"
echo "Working directory: /workspace/project"
echo "Type 'exit' to quit"
echo ""

docker exec -it $CONTAINER_NAME sh -c "cd /workspace/project && /bin/bash || /bin/sh"
