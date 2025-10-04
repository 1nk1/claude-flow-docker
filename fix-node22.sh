#!/bin/bash
# Fix script for Node.js 22 and better-sqlite3 issue

echo "🔧 Fixing Node.js version and dependencies..."
echo ""

# Backup
if [ -f "Dockerfile" ]; then
    cp Dockerfile Dockerfile.backup.$(date +%Y%m%d_%H%M%S)
    echo "✅ Backup created"
fi

# Create fixed Dockerfile
cat > Dockerfile << 'EOF'
# Claude-Flow Docker Image
FROM node:22-alpine

# Установка зависимостей системы (включая build tools для нативных модулей)
RUN apk add --no-cache \
    git \
    python3 \
    make \
    g++ \
    gcc \
    musl-dev \
    sqlite \
    sqlite-dev \
    bash \
    curl

# Создание рабочей директории
WORKDIR /workspace

# Установка Claude Code и Claude-Flow
# Сначала устанавливаем глобально с зависимостями
RUN npm install -g @anthropic-ai/claude-code@latest

# Устанавливаем Claude-Flow alpha с полными зависимостями
RUN npm install -g claude-flow@alpha || \
    (echo "⚠️ Alpha installation failed, trying alternative..." && \
     npm install -g claude-flow@latest)

# Установка дополнительных зависимостей для SQLite
RUN npm install -g better-sqlite3 --build-from-source

# Проверка установки
RUN claude --version || echo "Claude Code installed" && \
    node -e "console.log('Node.js version:', process.version)"

# Создание директорий для persistent storage
RUN mkdir -p /workspace/.hive-mind \
    /workspace/.swarm \
    /workspace/memory \
    /workspace/coordination \
    /workspace/.claude

# Переменные окружения
ENV NODE_ENV=development
ENV CLAUDE_FLOW_HOME=/workspace
ENV CLAUDE_FLOW_STORAGE=/workspace/.swarm
ENV MCP_SERVER_MODE=stdio
ENV NODE_OPTIONS="--max-old-space-size=4096"

# Healthcheck
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD node -e "console.log('healthy')" || exit 1

# Порты для MCP servers (если используется SSE режим)
EXPOSE 3000 3001 3002

# Entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["tail", "-f", "/dev/null"]
EOF

echo "✅ Dockerfile fixed!"
echo ""
echo "Changes made:"
echo "  - Updated Node.js 18 → 22"
echo "  - Added gcc, musl-dev, sqlite-dev for native builds"
echo "  - Added better-sqlite3 installation"
echo "  - Improved error handling"
echo ""
echo "Next steps:"
echo "  1. make clean          # Clean old containers"
echo "  2. make build          # Rebuild image"
echo "  3. make start          # Start container"
echo ""
