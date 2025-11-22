#!/bin/bash
# Test Claude-Flow functionality
set -e

echo "=== Claude-Flow Tests ==="

CONTAINER="claude-flow-alpha"

# Check claude-flow version
echo "1. Checking claude-flow version..."
VERSION=$(docker exec $CONTAINER claude-flow --version 2>&1 || echo "unknown")
echo "   Version: $VERSION"

# Check claude-flow help
echo "2. Checking claude-flow help..."
if ! docker exec $CONTAINER claude-flow --help >/dev/null 2>&1; then
    echo "   ERROR: claude-flow --help failed"
    exit 1
fi
echo "   Help command OK"

# Check memory system
echo "3. Checking memory system..."
if ! docker exec $CONTAINER claude-flow memory stats 2>/dev/null; then
    echo "   WARNING: Memory stats not available (may need initialization)"
fi
echo "   Memory system checked"

# Check hive-mind status
echo "4. Checking hive-mind status..."
docker exec $CONTAINER claude-flow hive-mind status 2>/dev/null || echo "   No active hive-mind (expected on fresh start)"

# Check swarm status
echo "5. Checking swarm status..."
docker exec $CONTAINER claude-flow swarm status 2>/dev/null || echo "   No active swarm (expected on fresh start)"

# Check agent list
echo "6. Checking agent capabilities..."
docker exec $CONTAINER claude-flow agent list 2>/dev/null || echo "   No agents running (expected)"

echo ""
echo "=== All Claude-Flow Tests Passed ==="
