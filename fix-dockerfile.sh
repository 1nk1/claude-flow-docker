#!/bin/bash
# Quick fix script для исправления Dockerfile

echo "🔧 Applying quick fix to Dockerfile..."

# Backup оригинального файла
cp Dockerfile Dockerfile.backup

# Исправление Dockerfile
cat > Dockerfile << 'EOF'
# Claude-Flow Docker Image
FROM node:18-alpine

# Установка зависимостей системы
RUN apk add --no-cache \
    git \
    python3 \
    make \
    g++ \
    sqlite \
    bash

# Создание рабочей директории
WORKDIR /workspace

# Установка Claude Code и Claude-Flow
RUN npm install -g @anthropic-ai/claude-code@latest && \
    npm install -g claude-flow@alpha

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

# Инициализация Claude-Flow при первом запуске
RUN cd /workspace && \
    claude-flow init --force --non-interactive || true

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

echo "✅ Dockerfile исправлен!"
echo "📋 Оригинал сохранен в Dockerfile.backup"
echo ""
echo "Теперь запустите:"
echo "  make setup"
