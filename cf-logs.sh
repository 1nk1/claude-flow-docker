#!/bin/bash
# View Claude-Flow container logs

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "📋 Viewing Claude-Flow logs..."
echo "======================================"
echo "(Press Ctrl+C to stop)"
echo ""

docker-compose logs -f --tail=100
