#!/bin/bash
set -e

echo "🚀 Starting Claude-Flow container..."

# Проверка Node.js версии
NODE_VERSION=$(node --version)
echo "📦 Node.js: $NODE_VERSION"

# Проверка Claude-Flow
if command -v claude-flow &> /dev/null; then
    CLAUDE_FLOW_VERSION=$(claude-flow --version 2>&1 | head -1 || echo "unknown")
    echo "🐝 Claude-Flow: $CLAUDE_FLOW_VERSION"
else
    echo "⚠️  Claude-Flow not found, attempting installation..."
    npm install -g claude-flow@alpha || npm install -g claude-flow@latest
fi

# Проверка better-sqlite3
if ! node -e "require('better-sqlite3')" 2>/dev/null; then
    echo "⚠️  better-sqlite3 not found, installing..."
    npm install -g better-sqlite3 --build-from-source
fi

# Инициализация директорий если не существуют
mkdir -p /workspace/.hive-mind \
         /workspace/.swarm \
         /workspace/memory \
         /workspace/coordination \
         /workspace/logs \
         /workspace/project

# Проверка и инициализация Claude-Flow
if [ ! -f "/workspace/.swarm/memory.db" ]; then
    echo "📦 Initializing Claude-Flow for the first time..."
    cd /workspace/project
    claude-flow init --force --non-interactive || true
    echo "✅ Claude-Flow initialized"
else
    echo "✅ Claude-Flow already initialized"
fi

# Проверка MCP серверов
echo "🔍 Checking MCP servers..."
if [ -f "/workspace/.claude/settings.json" ]; then
    echo "✅ MCP configuration found"
else
    echo "⚠️  No MCP configuration found, creating default..."
    mkdir -p /workspace/.claude
    cat > /workspace/.claude/settings.json <<'EOF'
{
  "mcpServers": {
    "claude-flow": {
      "command": "npx",
      "args": ["claude-flow", "mcp"],
      "env": {
        "CLAUDE_FLOW_HOME": "/workspace",
        "CLAUDE_FLOW_PROJECT": "/workspace/project"
      }
    }
  },
  "hooks": {
    "preEditHook": {
      "command": "npx",
      "args": ["claude-flow", "hooks", "pre-edit", "--file", "${file}"],
      "alwaysRun": false
    },
    "postEditHook": {
      "command": "npx",
      "args": ["claude-flow", "hooks", "post-edit", "--file", "${file}"],
      "alwaysRun": true
    }
  }
}
EOF
fi

# Логирование статуса
echo "📊 Claude-Flow Status:"
cd /workspace/project
claude-flow hive-mind status || echo "No active hive-mind sessions"

# Информация о контейнере
echo "
====================================
🐝 Claude-Flow Container Ready!
====================================
Container: claude-flow-alpha
Node.js: $(node --version)
Claude-Flow: $(claude-flow --version 2>/dev/null || echo 'alpha')
Project Dir: /workspace/project
Memory DB: /workspace/.swarm/memory.db
====================================
"

# Выполнение переданной команды или keep alive
exec "$@"
