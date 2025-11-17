#!/bin/bash
set -e

# ═══════════════════════════════════════════════════════════════════════════
# Claude-Flow Docker Container Entrypoint
# Advanced logging and initialization
# ═══════════════════════════════════════════════════════════════════════════

# Load logger library
if [[ -f /workspace/lib/logger.sh ]]; then
    source /workspace/lib/logger.sh
else
    # Fallback minimal logging if logger not available
    log_info() { echo "[INFO] $1"; }
    log_success() { echo "[SUCCESS] $1"; }
    log_warn() { echo "[WARN] $1"; }
    log_error() { echo "[ERROR] $1"; }
    log_header() { echo "=== $1 ==="; }
    log_section() { echo ">> $1"; }
fi

# ═══════════════════════════════════════════════════════════════════════════
# Environment Variables
# ═══════════════════════════════════════════════════════════════════════════

export CLAUDE_FLOW_HOME="${CLAUDE_FLOW_HOME:-/workspace}"
export CLAUDE_FLOW_PROJECT="${CLAUDE_FLOW_PROJECT:-/workspace/project}"
export CLAUDE_FLOW_STORAGE="${CLAUDE_FLOW_STORAGE:-/workspace/.swarm}"
export MCP_SERVER_PORT="${MCP_SERVER_PORT:-3000}"
export NODE_ENV="${NODE_ENV:-production}"
export LOG_LEVEL="${LOG_LEVEL:-INFO}"

# ═══════════════════════════════════════════════════════════════════════════
# Startup Banner
# ═══════════════════════════════════════════════════════════════════════════

log_header "🐳 CLAUDE-FLOW DOCKER CONTAINER"

log_info "Container: $(hostname)"
log_info "User: $(whoami)"
log_info "Started: $(date '+%Y-%m-%d %H:%M:%S %Z')"
log_info "Log Level: $LOG_LEVEL"

# ═══════════════════════════════════════════════════════════════════════════
# System Information
# ═══════════════════════════════════════════════════════════════════════════

log_section "System Information"

log_metric "Platform" "$(uname -s)"
log_metric "Architecture" "$(uname -m)"
log_metric "Kernel" "$(uname -r)"

if command -v free &>/dev/null; then
    local total_mem=$(free -m | awk 'NR==2{print $2}')
    log_metric "Memory" "${total_mem}MB" "total"
fi

# ═══════════════════════════════════════════════════════════════════════════
# Node.js Environment
# ═══════════════════════════════════════════════════════════════════════════

log_section "Node.js Environment"

if command -v node &>/dev/null; then
    NODE_VERSION=$(node --version)
    log_success "Node.js: $NODE_VERSION"
    log_to_file "INFO" "Node.js version: $NODE_VERSION" "NODEJS"
else
    log_error "Node.js not found!"
    exit 1
fi

if command -v npm &>/dev/null; then
    NPM_VERSION=$(npm --version)
    log_success "npm: v$NPM_VERSION"
    log_to_file "INFO" "npm version: $NPM_VERSION" "NODEJS"
else
    log_error "npm not found!"
    exit 1
fi

# ═══════════════════════════════════════════════════════════════════════════
# Claude Code
# ═══════════════════════════════════════════════════════════════════════════

log_section "Claude Code CLI"

if command -v claude &>/dev/null; then
    CLAUDE_VERSION=$(claude --version 2>&1 | head -1 || echo 'installed')
    log_success "Claude Code: $CLAUDE_VERSION"
    log_to_file "INFO" "Claude Code: $CLAUDE_VERSION" "CLAUDE"
else
    log_warn "Claude Code CLI not found (optional)"
fi

# ═══════════════════════════════════════════════════════════════════════════
# Claude-Flow Installation
# ═══════════════════════════════════════════════════════════════════════════

log_section "Claude-Flow Framework"

if command -v claude-flow &>/dev/null; then
    CLAUDE_FLOW_VERSION=$(npx claude-flow@alpha --version 2>&1 | head -1 || echo 'alpha')
    log_success "Claude-Flow: $CLAUDE_FLOW_VERSION"
    log_to_file "INFO" "Claude-Flow version: $CLAUDE_FLOW_VERSION" "CLAUDE-FLOW"
else
    log_warn "Claude-Flow not found, installing..."
    log_command "npm install -g claude-flow@alpha" "Installing Claude-Flow alpha"

    npm install -g claude-flow@alpha 2>&1 | while IFS= read -r line; do
        log_trace "$line" "NPM"
    done

    if command -v claude-flow &>/dev/null; then
        log_success "Claude-Flow installed successfully"
    else
        log_error "Failed to install Claude-Flow"
        exit 1
    fi
fi

# ═══════════════════════════════════════════════════════════════════════════
# Cleanup
# ═══════════════════════════════════════════════════════════════════════════

log_section "Cleanup"

log_command "rm -rf /usr/local/lib/node_modules/.better-sqlite3*" "Removing temp files"
rm -rf /usr/local/lib/node_modules/.better-sqlite3* 2>/dev/null && log_success "Temp files cleaned" || log_debug "No temp files to clean"

# ═══════════════════════════════════════════════════════════════════════════
# Directory Structure
# ═══════════════════════════════════════════════════════════════════════════

log_section "Directory Structure"

DIRECTORIES=(
    "/workspace/.hive-mind"
    "/workspace/.swarm"
    "/workspace/memory"
    "/workspace/coordination"
    "/workspace/logs"
    "/workspace/project"
    "/workspace/.claude"
    "/workspace/lib"
)

log_debug "Creating required directories..." "SETUP"

for dir in "${DIRECTORIES[@]}"; do
    if mkdir -p "$dir" 2>/dev/null; then
        log_trace "✓ $dir" "SETUP"
    else
        log_warn "Failed to create: $dir"
    fi
done

log_success "All directories ready"

# ═══════════════════════════════════════════════════════════════════════════
# Claude-Flow Initialization
# ═══════════════════════════════════════════════════════════════════════════

log_section "Claude-Flow Initialization"

cd /workspace/project

MEMORY_DB="/workspace/.swarm/memory.db"

if [[ ! -f "$MEMORY_DB" ]]; then
    log_warn "Memory database not found, initializing..."
    log_command "npx claude-flow@alpha init --force" "Initializing Claude-Flow"

    npx claude-flow@alpha init --force 2>&1 | while IFS= read -r line; do
        if [[ "$line" =~ ✓|Success|initialized ]]; then
            log_success "$line"
        else
            log_trace "$line" "INIT"
        fi
    done

    if [[ -f "$MEMORY_DB" ]]; then
        DB_SIZE=$(du -sh "$MEMORY_DB" | cut -f1)
        log_success "Memory DB created: $DB_SIZE"
        log_metric "Database Size" "$DB_SIZE"
    else
        log_error "Failed to create memory database"
        exit 1
    fi
else
    DB_SIZE=$(du -sh "$MEMORY_DB" | cut -f1)
    log_success "Memory DB exists: $DB_SIZE"
    log_metric "Database Size" "$DB_SIZE"

    # Check database integrity
    if sqlite3 "$MEMORY_DB" "PRAGMA integrity_check;" &>/dev/null; then
        log_debug "Database integrity check: PASSED" "DB"
    else
        log_warn "Database integrity check failed, may need repair"
    fi
fi

# ═══════════════════════════════════════════════════════════════════════════
# MCP Configuration
# ═══════════════════════════════════════════════════════════════════════════

log_section "MCP Server Configuration"

MCP_CONFIG_FILE="/workspace/.claude/mcp-config-template.json"

log_debug "Generating MCP configuration..." "MCP"

cat > "$MCP_CONFIG_FILE" << 'EOFMCP'
{
  "mcpServers": {
    "claude-flow": {
      "command": "docker",
      "args": ["exec", "-i", "claude-flow-alpha", "npx", "claude-flow@alpha", "mcp", "start"],
      "env": {
        "CLAUDE_FLOW_HOME": "/workspace",
        "CLAUDE_FLOW_PROJECT": "/workspace/project",
        "CLAUDE_FLOW_STORAGE": "/workspace/.swarm",
        "LOG_LEVEL": "INFO"
      }
    }
  }
}
EOFMCP

if [[ -f "$MCP_CONFIG_FILE" ]]; then
    log_success "MCP config created: $MCP_CONFIG_FILE"
    log_mcp_event "CONFIG" "Template ready for local connection"
else
    log_error "Failed to create MCP config"
fi

# ═══════════════════════════════════════════════════════════════════════════
# Environment Summary
# ═══════════════════════════════════════════════════════════════════════════

log_section "Environment Variables"

ENV_VARS=(
    "CLAUDE_FLOW_HOME:$CLAUDE_FLOW_HOME"
    "CLAUDE_FLOW_PROJECT:$CLAUDE_FLOW_PROJECT"
    "CLAUDE_FLOW_STORAGE:$CLAUDE_FLOW_STORAGE"
    "MCP_SERVER_PORT:$MCP_SERVER_PORT"
    "NODE_ENV:$NODE_ENV"
    "LOG_LEVEL:$LOG_LEVEL"
)

for env_var in "${ENV_VARS[@]}"; do
    IFS=: read -r name value <<< "$env_var"
    log_metric "$name" "$value"
done

# ═══════════════════════════════════════════════════════════════════════════
# Hive-Mind Status
# ═══════════════════════════════════════════════════════════════════════════

log_section "Hive-Mind Status"

HIVE_STATUS=$(npx claude-flow@alpha hive-mind status 2>/dev/null || echo "")

if [[ -n "$HIVE_STATUS" ]]; then
    log_info "$HIVE_STATUS"
else
    log_debug "No active hive-mind sessions" "HIVE-MIND"
fi

# ═══════════════════════════════════════════════════════════════════════════
# MCP Server Test
# ═══════════════════════════════════════════════════════════════════════════

log_section "MCP Server Verification"

log_debug "Testing MCP server availability..." "MCP"

# Test if MCP can be invoked
if timeout 5 npx claude-flow@alpha mcp --help &>/dev/null; then
    log_success "MCP server is ready"
    log_mcp_event "STATUS" "Server operational"
else
    log_warn "MCP server test timed out (this is normal on first run)"
fi

# ═══════════════════════════════════════════════════════════════════════════
# Usage Information
# ═══════════════════════════════════════════════════════════════════════════

log_header "📚 USAGE INFORMATION"

cat << 'USAGE'

╔════════════════════════════════════════════════════════════════════╗
║                      🚀 QUICK START COMMANDS                       ║
╚════════════════════════════════════════════════════════════════════╝

┌─ Interactive Shell ───────────────────────────────────────────────┐
│ docker exec -it claude-flow-alpha sh                              │
│ cd /workspace/project                                             │
│ claude                                                            │
└───────────────────────────────────────────────────────────────────┘

┌─ Claude-Flow Commands ────────────────────────────────────────────┐
│ npx claude-flow@alpha --help                                      │
│ npx claude-flow@alpha swarm create "build REST API"              │
│ npx claude-flow@alpha hive-mind spawn "implement feature"        │
│ npx claude-flow@alpha memory stats                               │
│ npx claude-flow@alpha agent list                                 │
└───────────────────────────────────────────────────────────────────┘

┌─ MCP Connection ──────────────────────────────────────────────────┐
│ 1. Copy MCP config to your project:                              │
│    cp /workspace/.claude/mcp-config-template.json \              │
│       ~/your-project/.claude/settings.json                       │
│                                                                   │
│ 2. Start Claude Code in your project:                            │
│    cd ~/your-project && claude                                   │
│                                                                   │
│ 3. Test MCP connection:                                          │
│    claude mcp list                                               │
└───────────────────────────────────────────────────────────────────┘

┌─ Logging ─────────────────────────────────────────────────────────┐
│ tail -f /workspace/logs/claude-flow.log    # Live logs           │
│ docker logs -f claude-flow-alpha           # Container logs      │
│ docker exec claude-flow-alpha \                                  │
│   cat /workspace/logs/claude-flow.log      # Full log file       │
└───────────────────────────────────────────────────────────────────┘

USAGE

# ═══════════════════════════════════════════════════════════════════════════
# Readiness Status
# ═══════════════════════════════════════════════════════════════════════════

log_header "✅ CONTAINER READY"

log_success "Container Name: claude-flow-alpha"
log_success "MCP Server: Ready for stdio connections via docker exec"
log_success "Protocol: stdio (not TCP)"
log_success "Log File: /workspace/logs/claude-flow.log"

log_blank
log_mcp_event "READY" "Add config to your project's .claude/settings.json"
log_mcp_event "TEMPLATE" "docker exec claude-flow-alpha cat /workspace/.claude/mcp-config-template.json"

log_separator
log_blank

# ═══════════════════════════════════════════════════════════════════════════
# Log Statistics
# ═══════════════════════════════════════════════════════════════════════════

if [[ -f "$LOG_FILE" ]]; then
    log_stats
fi

# ═══════════════════════════════════════════════════════════════════════════
# Keep Container Running
# ═══════════════════════════════════════════════════════════════════════════

log_info "Container initialized successfully"
log_info "Keeping container alive... (Press Ctrl+C to stop)"
log_blank

# Keep container running without starting TCP server
exec tail -f /dev/null
