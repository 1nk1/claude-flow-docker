#!/bin/bash
set -e

# ═══════════════════════════════════════════════════════════════════════════
# Claude-Flow Docker Container Entrypoint
# Clean, minimal output
# ═══════════════════════════════════════════════════════════════════════════

# Colors
RST='\e[0m' B='\e[1m' DIM='\e[2m'
GRN='\e[92m' CYN='\e[96m' YEL='\e[93m' RED='\e[91m' GRY='\e[90m'

ok() { echo -e "${GRN}✓${RST} $1"; }
info() { echo -e "${CYN}›${RST} $1"; }
warn() { echo -e "${YEL}!${RST} $1"; }
err() { echo -e "${RED}✗${RST} $1"; }

# ═══════════════════════════════════════════════════════════════════════════
# Environment
# ═══════════════════════════════════════════════════════════════════════════

export CLAUDE_FLOW_HOME="${CLAUDE_FLOW_HOME:-/workspace}"
export CLAUDE_FLOW_PROJECT="${CLAUDE_FLOW_PROJECT:-/workspace/project}"
export CLAUDE_FLOW_STORAGE="${CLAUDE_FLOW_STORAGE:-/workspace/.swarm}"
export NODE_ENV="${NODE_ENV:-production}"

# ═══════════════════════════════════════════════════════════════════════════
# Banner
# ═══════════════════════════════════════════════════════════════════════════

echo -e "\n${B}${CYN}Claude-Flow Container${RST}"
echo -e "${GRY}$(date '+%Y-%m-%d %H:%M:%S')${RST}\n"

# ═══════════════════════════════════════════════════════════════════════════
# Check dependencies
# ═══════════════════════════════════════════════════════════════════════════

command -v node &>/dev/null && ok "Node $(node --version)" || { err "Node.js not found"; exit 1; }
command -v npm &>/dev/null && ok "npm v$(npm --version)" || { err "npm not found"; exit 1; }
command -v claude &>/dev/null && ok "Claude CLI" || warn "Claude CLI not found"
command -v claude-flow &>/dev/null && ok "Claude-Flow $(claude-flow --version 2>/dev/null | head -1)" || {
    info "Installing claude-flow..."
    npm install -g claude-flow@alpha &>/dev/null && ok "Claude-Flow installed" || err "Install failed"
}

# ═══════════════════════════════════════════════════════════════════════════
# Setup directories
# ═══════════════════════════════════════════════════════════════════════════

mkdir -p /workspace/{.hive-mind,.swarm,memory,coordination,logs,project,.claude,lib} 2>/dev/null

# Install wrapper if exists
if [[ -f /workspace/lib/claude-flow-wrapper.sh ]]; then
    cp /workspace/lib/claude-flow-wrapper.sh /usr/local/bin/claude-flow
    chmod 755 /usr/local/bin/claude-flow
fi

# Load agent logger
[[ -f /workspace/lib/agent-logger.sh ]] && source /workspace/lib/agent-logger.sh

# ═══════════════════════════════════════════════════════════════════════════
# Initialize if needed
# ═══════════════════════════════════════════════════════════════════════════

cd /workspace/project

if [[ ! -f /workspace/.swarm/memory.db ]]; then
    info "Initializing..."
    timeout 30 claude-flow init --force &>/dev/null && ok "Initialized" || warn "Init skipped"
fi

# ═══════════════════════════════════════════════════════════════════════════
# MCP Config
# ═══════════════════════════════════════════════════════════════════════════

cat > /workspace/.claude/mcp-config-template.json << 'EOF'
{
  "mcpServers": {
    "claude-flow": {
      "command": "docker",
      "args": ["exec", "-i", "claude-flow-alpha", "claude-flow", "mcp", "start"]
    }
  }
}
EOF

# ═══════════════════════════════════════════════════════════════════════════
# External project info
# ═══════════════════════════════════════════════════════════════════════════

if [[ -d /workspace/external ]]; then
    EXT_COUNT=$(ls -1 /workspace/external 2>/dev/null | wc -l)
    ok "External projects: $EXT_COUNT mounted"
fi

# ═══════════════════════════════════════════════════════════════════════════
# Ready
# ═══════════════════════════════════════════════════════════════════════════

echo -e "\n${B}Ready${RST}"
echo -e "${GRY}─────────────────────────────────────${RST}"
echo -e "  ${DIM}Shell:${RST}     docker exec -it claude-flow-alpha sh"
echo -e "  ${DIM}Dashboard:${RST} ./live-dashboard.sh"
echo -e "  ${DIM}Logs:${RST}      docker logs -f claude-flow-alpha"
echo -e "${GRY}─────────────────────────────────────${RST}\n"

exec tail -f /dev/null
