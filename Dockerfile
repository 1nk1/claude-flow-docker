FROM node:22-slim

# Install dependencies for building C++ modules and ONNX runtime
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    python3-dev \
    python3-pip \
    build-essential \
    make \
    g++ \
    gcc \
    zsh \
    sqlite3 \
    libsqlite3-dev \
    git \
    vim \
    bash \
    curl \
    jq \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

# Update npm to latest version
RUN npm install -g npm@11.6.2

# Install Claude Code (must be installed first)
RUN npm install -g @anthropic-ai/claude-code@latest

# Install Claude Flow v2.7.15 with AgentDB v1.3.9 and ReasoningBank (1nk1 fork published)
# Features: 96x-164x faster vector search, 2-3ms query latency, 25 Skills, WASM-powered memory
# Description: "Enterprise-grade AI agent orchestration with WASM-powered ReasoningBank memory and AgentDB vector database"
# Using Debian base for full ONNX runtime support (glibc)
RUN npm install -g claude-flow@2.7.15

# Create user and configure permissions (Debian uses groupadd/useradd)
RUN groupadd -r appgroup && \
    useradd -r -g appgroup -s /bin/bash -m -d /home/appuser appuser && \
    mkdir -p /workspace/.hive-mind /workspace/.swarm /workspace/memory /workspace/coordination /workspace/.claude /workspace/lib /workspace/logs && \
    mkdir -p /home/appuser/.npm /home/appuser/.cache && \
    chown -R appuser:appgroup /workspace /home/appuser

# SECURITY: Flow-nexus authentication moved to runtime via environment variables
# Set FLOW_NEXUS_EMAIL and FLOW_NEXUS_PASSWORD in .env file
# Authentication will be performed in docker-entrypoint.sh if needed

RUN chown -R appuser:appgroup /usr/local/lib/node_modules

# Copy logger library
COPY lib/logger.sh /workspace/lib/
RUN chmod +x /workspace/lib/logger.sh && chown appuser:appgroup /workspace/lib/logger.sh

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

USER appuser
WORKDIR /workspace/project

EXPOSE 3000 8811

ENTRYPOINT ["docker-entrypoint.sh"]
