#!/bin/bash
# Test Docker Build
set -e

echo "=== Docker Build Tests ==="

# Check if container is running
echo "1. Checking container status..."
if ! docker ps | grep -q claude-flow-alpha; then
    echo "ERROR: Container claude-flow-alpha is not running"
    exit 1
fi
echo "   Container is running"

# Check Node.js version
echo "2. Checking Node.js version..."
NODE_VERSION=$(docker exec claude-flow-alpha node --version)
if [[ ! "$NODE_VERSION" =~ ^v22 ]]; then
    echo "   WARNING: Node.js version is $NODE_VERSION (expected v22.x)"
else
    echo "   Node.js $NODE_VERSION"
fi

# Check working directory
echo "3. Checking working directory..."
WORKDIR=$(docker exec claude-flow-alpha pwd)
if [ "$WORKDIR" != "/workspace" ]; then
    echo "   ERROR: Working directory is $WORKDIR (expected /workspace)"
    exit 1
fi
echo "   Working directory: $WORKDIR"

# Check required directories
echo "4. Checking required directories..."
for DIR in /workspace/.hive-mind /workspace/.swarm /workspace/memory /workspace/logs; do
    if ! docker exec claude-flow-alpha test -d "$DIR"; then
        echo "   ERROR: Directory $DIR does not exist"
        exit 1
    fi
    echo "   $DIR exists"
done

# Check better-sqlite3
echo "5. Checking better-sqlite3..."
if ! docker exec claude-flow-alpha node -e "require('better-sqlite3')" 2>/dev/null; then
    echo "   ERROR: better-sqlite3 not working"
    exit 1
fi
echo "   better-sqlite3 OK"

echo ""
echo "=== All Docker Build Tests Passed ==="
