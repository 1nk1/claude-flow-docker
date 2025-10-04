#!/bin/bash
# Start Claude-Flow Docker container

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "🚀 Starting Claude-Flow container..."

# Проверка наличия .env файла
if [ ! -f ".env" ]; then
    echo "⚠️  .env file not found. Using defaults from .env.example"
    cp .env.example .env
fi

# Запуск контейнера
docker-compose up -d

# Ожидание готовности контейнера
echo "⏳ Waiting for container to be ready..."
sleep 3

# Проверка статуса
if docker ps | grep -q claude-flow-alpha; then
    echo "✅ Claude-Flow container is running!"
    echo ""
    echo "📊 Container status:"
    docker-compose ps
    echo ""
    echo "📋 Available commands:"
    echo "   ./cf-exec.sh claude-flow --help    - View Claude-Flow help"
    echo "   ./cf-exec.sh claude-flow hive-mind status - Check hive-mind status"
    echo "   ./cf-logs.sh                      - View logs"
    echo "   ./cf-shell.sh                     - Interactive shell"
    echo ""
    echo "🔗 To connect Claude Code to this container:"
    echo "   Copy config/.claude/settings.json to your project root"
    echo ""
else
    echo "❌ Failed to start container. Check logs with: docker-compose logs"
    exit 1
fi
