#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# Claude-Flow Project Switcher
# Быстрое переключение между проектами
# ═══════════════════════════════════════════════════════════════

set -e

# Цвета
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

ENV_FILE=".env"
BACKUP_DIR="backups"
CONTAINER_NAME="claude-flow-alpha"

# ═══════════════════════════════════════════════════════════════
# LOGGING FUNCTIONS
# ═══════════════════════════════════════════════════════════════

log_info() {
    echo -e "${BLUE}  [INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN} [SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}  [WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED} [ERROR]${NC} $1"
}

# ═══════════════════════════════════════════════════════════════
# BANNER
# ═══════════════════════════════════════════════════════════════

clear
echo -e "${PURPLE}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${PURPLE}║   Claude-Flow Project Switcher${NC}                         ${PURPLE}║${NC}"
echo -e "${PURPLE}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""

# ═══════════════════════════════════════════════════════════════
# CHECK ENVIRONMENT
# ═══════════════════════════════════════════════════════════════

if [ ! -f "$ENV_FILE" ]; then
    log_error ".env file not found!"
    echo ""
    echo "Please run setup first: ./setup.sh"
    exit 1
fi

# ═══════════════════════════════════════════════════════════════
# GET CURRENT PROJECT
# ═══════════════════════════════════════════════════════════════

CURRENT_PROJECT=$(grep "^PROJECT_PATH=" "$ENV_FILE" | cut -d'=' -f2)

if [ -z "$CURRENT_PROJECT" ]; then
    log_warning "No project currently configured"
    CURRENT_PROJECT="<none>"
else
    log_info "Current project: ${CYAN}${CURRENT_PROJECT}${NC}"
fi

echo ""

# ═══════════════════════════════════════════════════════════════
# INTERACTIVE OR ARGUMENT MODE
# ═══════════════════════════════════════════════════════════════

if [ $# -eq 0 ]; then
    # Interactive mode
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}Interactive Project Selection${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    # Show recent projects (from history file)
    HISTORY_FILE=".project-history"

    if [ -f "$HISTORY_FILE" ]; then
        echo -e "${YELLOW}Recent projects:${NC}"
        nl -w 2 -s '. ' "$HISTORY_FILE"
        echo ""
        echo -e "${YELLOW}0. Enter new path manually${NC}"
        echo ""

        read -p "Select project number (or 0 for manual): " selection

        if [ "$selection" = "0" ]; then
            echo ""
            read -p "Enter project path: " NEW_PROJECT
        else
            NEW_PROJECT=$(sed -n "${selection}p" "$HISTORY_FILE")
            if [ -z "$NEW_PROJECT" ]; then
                log_error "Invalid selection"
                exit 1
            fi
        fi
    else
        echo -e "${YELLOW}No project history found${NC}"
        echo ""
        read -p "Enter project path: " NEW_PROJECT
    fi
else
    # Argument mode
    NEW_PROJECT="$1"
fi

# ═══════════════════════════════════════════════════════════════
# VALIDATE NEW PROJECT PATH
# ═══════════════════════════════════════════════════════════════

echo ""
log_info "Validating new project path..."

# Expand tilde
NEW_PROJECT="${NEW_PROJECT/#\~/$HOME}"

# Check if path exists
if [ ! -d "$NEW_PROJECT" ]; then
    log_warning "Directory does not exist: ${NEW_PROJECT}"
    echo ""
    read -p "Create directory? [y/N] " -n 1 -r
    echo

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        mkdir -p "$NEW_PROJECT"
        log_success "Created directory: ${NEW_PROJECT}"
    else
        log_error "Project path must exist. Aborting."
        exit 1
    fi
else
    log_success "Directory exists: ${NEW_PROJECT}"
fi

# Check if it's the same project
if [ "$NEW_PROJECT" = "$CURRENT_PROJECT" ]; then
    log_warning "This is already the current project!"
    exit 0
fi

# ═══════════════════════════════════════════════════════════════
# CREATE BACKUP (OPTIONAL)
# ═══════════════════════════════════════════════════════════════

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}Backup & Safety${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check if container is running
CONTAINER_RUNNING=false
if docker ps | grep -q "$CONTAINER_NAME"; then
    CONTAINER_RUNNING=true
    log_warning "Container is currently running"
fi

if [ "$CONTAINER_RUNNING" = true ]; then
    echo ""
    read -p "Create backup before switching? [Y/n] " -n 1 -r
    echo

    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        log_info "Creating backup..."
        mkdir -p "$BACKUP_DIR"

        TIMESTAMP=$(date +%Y%m%d-%H%M%S)

        # Backup volumes
        log_info "Backing up swarm data..."
        docker run --rm \
            -v claude-flow_claude-flow-swarm:/data \
            -v "$(pwd)/$BACKUP_DIR":/backup \
            alpine tar czf "/backup/swarm-${TIMESTAMP}.tar.gz" -C /data . 2>/dev/null

        log_info "Backing up hive-mind data..."
        docker run --rm \
            -v claude-flow_claude-flow-hive:/data \
            -v "$(pwd)/$BACKUP_DIR":/backup \
            alpine tar czf "/backup/hive-${TIMESTAMP}.tar.gz" -C /data . 2>/dev/null

        log_success "Backup created: ${BACKUP_DIR}/*-${TIMESTAMP}.tar.gz"
    fi
fi

# ═══════════════════════════════════════════════════════════════
# STOP CONTAINER
# ═══════════════════════════════════════════════════════════════

if [ "$CONTAINER_RUNNING" = true ]; then
    echo ""
    log_info "Stopping container..."
    docker-compose stop 2>/dev/null || true
    log_success "Container stopped"
fi

# ═══════════════════════════════════════════════════════════════
# UPDATE CONFIGURATION
# ═══════════════════════════════════════════════════════════════

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}Updating Configuration${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

log_info "Updating .env file..."

# Backup current .env
cp "$ENV_FILE" "${ENV_FILE}.bak"
log_info "Created backup: ${ENV_FILE}.bak"

# Update PROJECT_PATH in .env
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s|^PROJECT_PATH=.*|PROJECT_PATH=${NEW_PROJECT}|" "$ENV_FILE"
else
    sed -i "s|^PROJECT_PATH=.*|PROJECT_PATH=${NEW_PROJECT}|" "$ENV_FILE"
fi

log_success "Updated PROJECT_PATH in .env"

# Save to history
echo "$NEW_PROJECT" >> "$HISTORY_FILE"
# Keep only last 10 unique entries
sort -u "$HISTORY_FILE" | tail -10 > "${HISTORY_FILE}.tmp"
mv "${HISTORY_FILE}.tmp" "$HISTORY_FILE"

# ═══════════════════════════════════════════════════════════════
# PROJECT INFORMATION
# ═══════════════════════════════════════════════════════════════

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}Project Information${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check for package.json
if [ -f "$NEW_PROJECT/package.json" ]; then
    log_success "package.json found"

    # Extract project info
    if command -v jq &> /dev/null; then
        PROJECT_NAME=$(jq -r '.name // "unknown"' "$NEW_PROJECT/package.json")
        PROJECT_VERSION=$(jq -r '.version // "unknown"' "$NEW_PROJECT/package.json")
        log_info "Project: ${CYAN}${PROJECT_NAME}${NC} v${PROJECT_VERSION}"
    fi
else
    log_warning "No package.json found in project"
fi

# Check project size
PROJECT_SIZE=$(du -sh "$NEW_PROJECT" 2>/dev/null | cut -f1)
PROJECT_FILES=$(find "$NEW_PROJECT" -type f 2>/dev/null | wc -l | xargs)
log_info "Project size: ${PROJECT_SIZE} (${PROJECT_FILES} files)"

# ═══════════════════════════════════════════════════════════════
# RESTART CONTAINER
# ═══════════════════════════════════════════════════════════════

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}Starting Container${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

read -p "Start container with new project? [Y/n] " -n 1 -r
echo

if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    log_info "Starting container..."
    docker-compose up -d

    # Wait for container to be ready
    log_info "Waiting for container to be ready..."
    sleep 3

    # Check if container is running
    if docker ps | grep -q "$CONTAINER_NAME"; then
        log_success "Container started successfully"

        echo ""
        log_info "Verifying project mount..."
        docker exec "$CONTAINER_NAME" ls -la /workspace/project 2>/dev/null | head -5

        echo ""
        log_success "Project switched successfully!"
    else
        log_error "Container failed to start"
        log_info "Check logs: docker logs $CONTAINER_NAME"
        exit 1
    fi
else
    log_info "Container not started. Start manually: docker-compose up -d"
fi

# ═══════════════════════════════════════════════════════════════
# COMPLETION
# ═══════════════════════════════════════════════════════════════

echo ""
echo -e "${PURPLE}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${PURPLE}║  ${GREEN} Project Switch Complete!${NC}                               ${PURPLE}║${NC}"
echo -e "${PURPLE}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${CYAN} Summary:${NC}"
echo -e "  Previous: ${YELLOW}${CURRENT_PROJECT}${NC}"
echo -e "  Current:  ${GREEN}${NEW_PROJECT}${NC}"
echo ""

echo -e "${CYAN} Next Steps:${NC}"
echo -e "  • Check container status: ${BLUE}make status${NC}"
echo -e "  • View logs:             ${BLUE}make logs${NC}"
echo -e "  • Enter container:       ${BLUE}make shell${NC}"
echo -e "  • Initialize Claude-Flow: ${BLUE}make cf-init${NC}"
echo ""

echo -e "${CYAN} Backup Location:${NC}"
if [ -d "$BACKUP_DIR" ] && [ "$(ls -A $BACKUP_DIR)" ]; then
    echo -e "  ${BLUE}${BACKUP_DIR}/${NC}"
    ls -lth "$BACKUP_DIR" | head -3 | tail -2
fi

echo ""
