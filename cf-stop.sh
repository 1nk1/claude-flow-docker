#!/bin/bash
# Stop Claude-Flow Docker container

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "🛑 Stopping Claude-Flow container..."

docker-compose down

echo "✅ Claude-Flow container stopped"
echo ""
echo "📊 To remove all data (volumes), run:"
echo "   docker-compose down -v"
