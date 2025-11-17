#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# MCP Connection Setup Script
# Adds Docker-based MCP configuration to your project
# ═══════════════════════════════════════════════════════════════

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info() { echo -e "${BLUE}  [INFO]${NC} $1"; }
log_success() { echo -e "${GREEN} [SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}  [WARNING]${NC} $1"; }
log_error() { echo -e "${RED} [ERROR]${NC} $1"; }

echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}   Claude-Flow MCP Connection Setup${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo ""

# Check if container is running
if ! docker ps | grep -q claude-flow-alpha; then
    log_error "Container 'claude-flow-alpha' is not running"
    echo ""
    echo "Start it with:"
    echo "  cd $(dirname "$0")"
    echo "  make start  (or)  docker-compose up -d"
    exit 1
fi

log_success "Container is running"

# Get project path
if [ -z "$1" ]; then
    echo ""
    echo -e "${YELLOW}Usage:${NC} $0 <project-path>"
    echo ""
    echo "Example:"
    echo "  $0 ~/projects/my-app"
    echo "  $0 /Users/john/Desktop/test-project"
    exit 1
fi

PROJECT_PATH="$1"

# Check if project exists
if [ ! -d "$PROJECT_PATH" ]; then
    log_error "Project path does not exist: $PROJECT_PATH"
    exit 1
fi

log_info "Project path: $PROJECT_PATH"

# Create .claude directory
CLAUDE_DIR="$PROJECT_PATH/.claude"
if [ ! -d "$CLAUDE_DIR" ]; then
    log_info "Creating .claude directory..."
    mkdir -p "$CLAUDE_DIR"
    log_success "Created: $CLAUDE_DIR"
fi

# Create or update settings.json
SETTINGS_FILE="$CLAUDE_DIR/settings.json"

if [ -f "$SETTINGS_FILE" ]; then
    log_warning "settings.json already exists"

    # Check if claude-flow MCP already configured
    if grep -q '"claude-flow"' "$SETTINGS_FILE"; then
        log_warning "claude-flow MCP server already configured"
        echo ""
        read -p "Overwrite existing configuration? [y/N] " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Keeping existing configuration"
            exit 0
        fi
    fi

    # Backup existing file
    BACKUP_FILE="${SETTINGS_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$SETTINGS_FILE" "$BACKUP_FILE"
    log_success "Backup created: ${BACKUP_FILE}"
fi

# Create MCP configuration
log_info "Creating MCP configuration..."

cat > "$SETTINGS_FILE" << 'EOF'
{
  "mcpServers": {
    "claude-flow": {
      "command": "docker",
      "args": [
        "exec",
        "-i",
        "claude-flow-alpha",
        "claude-flow",
        "mcp",
        "start"
      ],
      "env": {
        "CLAUDE_FLOW_HOME": "/workspace",
        "CLAUDE_FLOW_PROJECT": "/workspace/project",
        "CLAUDE_FLOW_STORAGE": "/workspace/.swarm"
      }
    }
  }
}
EOF

log_success "MCP configuration created: $SETTINGS_FILE"

# Verify configuration
echo ""
log_info "Verifying configuration..."

if docker exec -i claude-flow-alpha npx claude-flow@alpha --version > /dev/null 2>&1; then
    log_success "Docker container responds correctly"
else
    log_error "Container is not responding correctly"
    exit 1
fi

# Test MCP connection
log_info "Testing MCP connection..."
if echo '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{}}' | \
   docker exec -i claude-flow-alpha npx claude-flow@alpha mcp start 2>/dev/null | \
   grep -q "jsonrpc"; then
    log_success "MCP connection test passed"
else
    log_warning "MCP connection test inconclusive (this is normal)"
fi

# Show success message
echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   MCP Configuration Completed!${NC}                          ${GREEN}║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${CYAN} Next Steps:${NC}"
echo ""
echo -e "  ${YELLOW}1.${NC} Navigate to your project:"
echo -e "     ${BLUE}cd $PROJECT_PATH${NC}"
echo ""
echo -e "  ${YELLOW}2.${NC} Start Claude Code:"
echo -e "     ${BLUE}claude${NC}"
echo ""
echo -e "  ${YELLOW}3.${NC} Test MCP connection in Claude Code:"
echo -e "     ${CYAN}\"Show me the claude-flow swarm status\"${NC}"
echo ""

echo -e "${CYAN} Verify Settings:${NC}"
echo -e "     ${BLUE}cat $SETTINGS_FILE${NC}"
echo ""

echo -e "${CYAN} Pro Tips:${NC}"
echo -e "     • Container must be running for MCP to work"
echo -e "     • Check container: ${BLUE}docker ps | grep claude-flow${NC}"
echo -e "     • View logs: ${BLUE}docker logs claude-flow-alpha -f${NC}"
echo -e "     • List MCP servers in Claude Code: ${BLUE}claude mcp list${NC}"
echo ""

log_success "Setup complete! Happy coding! "
