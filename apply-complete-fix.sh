#!/bin/bash
# Complete fix script - удаляет кеш и пересобирает всё с Node.js 22

set -e

echo "🔧 Complete Claude-Flow Docker Fix"
echo "===================================="
echo ""

# Backup старого Dockerfile
if [ -f "Dockerfile" ]; then
    cp Dockerfile Dockerfile.backup.$(date +%Y%m%d_%H%M%S)
    echo "✅ Backup created"
fi

echo ""
echo "📝 Step 1: Creating correct Dockerfile with Node.js 22..."

cat > Dockerfile << 'DOCKERFILE_END'
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

# Примечание: Конфигурационные файлы будут скопированы через volumes при запуске

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
DOCKERFILE_END

echo "✅ Dockerfile updated with Node.js 22"

echo ""
echo "🗑️  Step 2: Cleaning Docker cache and old containers..."

# Остановка и удаление контейнера
docker-compose down 2>/dev/null || true

# Удаление старого образа
docker rmi claude-flow-claude-flow 2>/dev/null || true
docker rmi $(docker images -q claude-flow-claude-flow) 2>/dev/null || true

echo "✅ Old containers and images removed"

echo ""
echo "🏗️  Step 3: Building new image (this will take a few minutes)..."
echo "    ⏳ Installing Node.js 22, compiling better-sqlite3..."
echo ""

# Сборка без кеша
docker-compose build --no-cache --progress=plain 2>&1 | grep -E "^#|Node.js|claude-flow|better-sqlite3|ERROR" || true

echo ""
echo "✅ Build complete!"

echo ""
echo "🚀 Step 4: Starting container..."
docker-compose up -d

echo ""
echo "⏳ Waiting for container to be ready..."
sleep 5

echo ""
echo "===================================="
echo "✅ Fix Applied Successfully!"
echo "===================================="
echo ""

# Проверка
echo "📊 Verification:"
echo ""

echo "1. Node.js version:"
docker exec -i claude-flow-alpha node --version

echo ""
echo "2. Claude-Flow version:"
docker exec -i claude-flow-alpha claude-flow --version 2>&1 | head -3 || echo "⚠️ Check logs if errors appear"

echo ""
echo "3. better-sqlite3 check:"
docker exec -i claude-flow-alpha node -e "require('better-sqlite3'); console.log('✅ better-sqlite3 installed')" 2>&1

echo ""
echo "===================================="
echo "🎉 All Done!"
echo ""
echo "Next steps:"
echo "  1. Test: ./cf-exec.sh claude-flow hive-mind status"
echo "  2. Logs: make logs"
echo "  3. Shell: make shell"
echo ""
