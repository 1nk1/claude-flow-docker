#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# Claude-Flow Docker Setup Script
# Automatic environment setup for development
# ═══════════════════════════════════════════════════════════════

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# ═══════════════════════════════════════════════════════════════
# BANNER
# ═══════════════════════════════════════════════════════════════

clear
echo -e "${PURPLE}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${PURPLE}║   Claude-Flow Docker Setup Wizard${NC}                      ${PURPLE}║${NC}"
echo -e "${PURPLE}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""

# ═══════════════════════════════════════════════════════════════
# DEPENDENCY CHECKS
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

log_step() {
    echo -e "${CYAN}$1${NC}"
}

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
log_step "Step 1: Checking System Dependencies"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Check Docker
log_info "Checking Docker installation..."
if ! command -v docker &> /dev/null; then
    log_error "Docker is not installed"
    echo ""
    echo "Please install Docker first:"
    echo "  macOS: brew install --cask docker"
    echo "  Linux: curl -fsSL https://get.docker.com | sh"
    echo "  Or visit: https://docs.docker.com/get-docker/"
    exit 1
fi

DOCKER_VERSION=$(docker --version | cut -d' ' -f3 | tr -d ',')
log_success "Docker installed: v${DOCKER_VERSION}"

# Check Docker Compose
log_info "Checking Docker Compose installation..."
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    log_error "Docker Compose is not installed"
    exit 1
fi

if docker compose version &> /dev/null; then
    COMPOSE_VERSION=$(docker compose version --short)
    COMPOSE_CMD="docker compose"
else
    COMPOSE_VERSION=$(docker-compose --version | cut -d' ' -f4 | tr -d ',')
    COMPOSE_CMD="docker-compose"
fi
log_success "Docker Compose installed: v${COMPOSE_VERSION}"

# Check Docker daemon
log_info "Checking Docker daemon..."
if ! docker info &> /dev/null; then
    log_error "Docker daemon is not running"
    echo ""
    echo "Please start Docker Desktop or run: sudo systemctl start docker"
    exit 1
fi
log_success "Docker daemon is running"

# Check available disk space
log_info "Checking disk space..."
AVAILABLE_SPACE=$(df -h . | awk 'NR==2 {print $4}')
log_info "Available disk space: ${AVAILABLE_SPACE}"

# Check make
if command -v make &> /dev/null; then
    log_success "Make is installed"
    HAS_MAKE=true
else
    log_warning "Make is not installed (optional, but recommended)"
    HAS_MAKE=false
fi

echo ""

# ═══════════════════════════════════════════════════════════════
# PROJECT STRUCTURE
# ═══════════════════════════════════════════════════════════════

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
log_step "Step 2: Creating Project Structure"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

DIRECTORIES=(
    "config/.claude"
    "config/.claude/sessions"
    "logs"
    "backups"
    "scripts"
)

for dir in "${DIRECTORIES[@]}"; do
    if [ ! -d "$dir" ]; then
        log_info "Creating directory: $dir"
        mkdir -p "$dir"
        log_success "Created: $dir"
    else
        log_info "Directory exists: $dir"
    fi
done

# Create .gitkeep files
touch config/.claude/.gitkeep
touch logs/.gitkeep
touch backups/.gitkeep

echo ""

# ═══════════════════════════════════════════════════════════════
# ENVIRONMENT CONFIGURATION
# ═══════════════════════════════════════════════════════════════

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
log_step "Step 3: Configuring Environment"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Check if .env exists
if [ -f ".env" ]; then
    log_warning ".env file already exists"
    echo ""
    read -p "Do you want to overwrite it? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Keeping existing .env file"
        ENV_CREATED=false
    else
        log_info "Creating new .env file from template..."
        cp .env.example .env
        ENV_CREATED=true
        log_success ".env file created"
    fi
else
    log_info "Creating .env file from template..."
    if [ -f ".env.example" ]; then
        cp .env.example .env
        ENV_CREATED=true
        log_success ".env file created"
    else
        log_error ".env.example not found!"
        exit 1
    fi
fi

# Interactive configuration
if [ "$ENV_CREATED" = true ]; then
    echo ""
    log_info "Let's configure your environment..."
    echo ""

    # Get current user's home directory
    USER_HOME="$HOME"

    # Ask for project path
    echo -e "${YELLOW}Enter the path to your project:${NC}"
    echo -e "  ${CYAN}Example: $USER_HOME/projects/my-app${NC}"
    read -p "Project path: " PROJECT_PATH

    if [ -z "$PROJECT_PATH" ]; then
        PROJECT_PATH="$USER_HOME/projects/tmp/casinoua-mobile-autotests"
        log_warning "Using default: $PROJECT_PATH"
    fi

    # Check if project path exists
    if [ ! -d "$PROJECT_PATH" ]; then
        log_warning "Project path does not exist: $PROJECT_PATH"
        read -p "Create it? [y/N] " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            mkdir -p "$PROJECT_PATH"
            log_success "Created: $PROJECT_PATH"
        fi
    else
        log_success "Project path exists: $PROJECT_PATH"
    fi

    # Update .env with project path
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s|^PROJECT_PATH=.*|PROJECT_PATH=$PROJECT_PATH|" .env
    else
        sed -i "s|^PROJECT_PATH=.*|PROJECT_PATH=$PROJECT_PATH|" .env
    fi

    log_success "Updated .env with project path"

    # Ask for desktop files path
    echo ""
    echo -e "${YELLOW}Enter the path to desktop files (optional):${NC}"
    echo -e "  ${CYAN}Example: $USER_HOME/Desktop/files${NC}"
    read -p "Desktop files path (or press Enter to skip): " DESKTOP_PATH

    if [ -n "$DESKTOP_PATH" ]; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "s|^DESKTOP_FILES_PATH=.*|DESKTOP_FILES_PATH=$DESKTOP_PATH|" .env
        else
            sed -i "s|^DESKTOP_FILES_PATH=.*|DESKTOP_FILES_PATH=$DESKTOP_PATH|" .env
        fi
        log_success "Updated .env with desktop files path"
    fi
fi

echo ""

# ═══════════════════════════════════════════════════════════════
# GIT CONFIGURATION
# ═══════════════════════════════════════════════════════════════

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
log_step "Step 4: Git Configuration"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Create .gitignore
log_info "Creating .gitignore..."
cat > .gitignore <<'EOF'
# Environment
.env
.env.local
.env.*.local

# Logs
logs/
*.log
npm-debug.log*

# Docker volumes
project/*
!project/.gitkeep

# Backups
backups/*.tar.gz

# OS files
.DS_Store
Thumbs.db
*.swp
*.swo
*~

# IDE
.vscode/*
!.vscode/settings.json
!.vscode/extensions.json
.idea/
*.iml
.project
.classpath
.settings/

# Node
node_modules/
package-lock.json

# Claude sessions
config/.claude/sessions/
*.session

# Temporary files
tmp/
temp/
*.tmp
EOF
log_success ".gitignore created"

# Create .dockerignore
log_info "Creating .dockerignore..."
cat > .dockerignore <<'EOF'
# Git
.git
.gitignore
.gitattributes

# Documentation
*.md
docs/

# Environment
.env
.env.*

# Logs
logs/
*.log

# Backups
backups/

# Docker
docker-compose*.yml
Dockerfile
.dockerignore

# IDE
.vscode/
.idea/

# OS files
.DS_Store
Thumbs.db

# Node
node_modules/
npm-debug.log

# CI
.github/
.gitlab-ci.yml

# Tests
test/
tests/
*.test.js
*.spec.js
EOF
log_success ".dockerignore created"

echo ""

# ═══════════════════════════════════════════════════════════════
# SCRIPTS PERMISSIONS
# ═══════════════════════════════════════════════════════════════

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
log_step "Step 5: Setting Script Permissions"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

SCRIPTS=(
    "setup.sh"
    "switch-project.sh"
    "docker-entrypoint.sh"
)

for script in "${SCRIPTS[@]}"; do
    if [ -f "$script" ]; then
        chmod +x "$script"
        log_success "Made executable: $script"
    else
        log_warning "Script not found: $script"
    fi
done

echo ""

# ═══════════════════════════════════════════════════════════════
# DOCKER IMAGE BUILD
# ═══════════════════════════════════════════════════════════════

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
log_step "Step 6: Building Docker Image"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

echo ""
read -p "Do you want to build the Docker image now? [Y/n] " -n 1 -r
echo

if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    log_info "Building Docker image... (this may take several minutes)"
    echo ""

    if $COMPOSE_CMD build; then
        log_success "Docker image built successfully"
    else
        log_error "Failed to build Docker image"
        exit 1
    fi
else
    log_info "Skipping Docker build. You can build later with: make build"
fi

echo ""

# ═══════════════════════════════════════════════════════════════
# VERIFICATION
# ═══════════════════════════════════════════════════════════════

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
log_step "Step 7: Verification"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

echo ""
log_info "Checking setup completeness..."

CHECKS_PASSED=0
CHECKS_TOTAL=0

# Check .env
((CHECKS_TOTAL++))
if [ -f ".env" ]; then
    log_success ".env file exists"
    ((CHECKS_PASSED++))
else
    log_error ".env file missing"
fi

# Check .gitignore
((CHECKS_TOTAL++))
if [ -f ".gitignore" ]; then
    log_success ".gitignore exists"
    ((CHECKS_PASSED++))
else
    log_error ".gitignore missing"
fi

# Check directories
((CHECKS_TOTAL++))
if [ -d "config/.claude" ] && [ -d "logs" ] && [ -d "backups" ]; then
    log_success "All required directories exist"
    ((CHECKS_PASSED++))
else
    log_error "Some directories missing"
fi

# Check Docker image
((CHECKS_TOTAL++))
if docker images | grep -q "claude-flow"; then
    log_success "Docker image exists"
    ((CHECKS_PASSED++))
else
    log_warning "Docker image not built yet"
fi

echo ""
log_info "Verification: ${CHECKS_PASSED}/${CHECKS_TOTAL} checks passed"

# ═══════════════════════════════════════════════════════════════
# COMPLETION
# ═══════════════════════════════════════════════════════════════

echo ""
echo -e "${PURPLE}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${PURPLE}║  ${GREEN} Setup Completed Successfully!${NC}                          ${PURPLE}║${NC}"
echo -e "${PURPLE}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${CYAN} Next Steps:${NC}"
echo ""
echo -e "  ${YELLOW}1.${NC} Review configuration:"
echo -e "     ${BLUE}cat .env${NC}"
echo ""
echo -e "  ${YELLOW}2.${NC} Start Claude-Flow container:"
if [ "$HAS_MAKE" = true ]; then
    echo -e "     ${BLUE}make start${NC}  (or)  ${BLUE}docker-compose up -d${NC}"
else
    echo -e "     ${BLUE}docker-compose up -d${NC}"
fi
echo ""
echo -e "  ${YELLOW}3.${NC} Check status:"
if [ "$HAS_MAKE" = true ]; then
    echo -e "     ${BLUE}make info${NC}  (or)  ${BLUE}docker-compose ps${NC}"
else
    echo -e "     ${BLUE}docker-compose ps${NC}"
fi
echo ""
echo -e "  ${YELLOW}4.${NC} View logs:"
if [ "$HAS_MAKE" = true ]; then
    echo -e "     ${BLUE}make logs${NC}  (or)  ${BLUE}docker logs claude-flow-alpha -f${NC}"
else
    echo -e "     ${BLUE}docker logs claude-flow-alpha -f${NC}"
fi
echo ""

if [ "$HAS_MAKE" = true ]; then
    echo -e "${CYAN} Available Make Commands:${NC}"
    echo -e "     ${BLUE}make help${NC}      - Show all available commands"
    echo -e "     ${BLUE}make start${NC}     - Start container"
    echo -e "     ${BLUE}make stop${NC}      - Stop container"
    echo -e "     ${BLUE}make shell${NC}     - Enter container shell"
    echo -e "     ${BLUE}make logs${NC}      - View logs"
    echo -e "     ${BLUE}make backup${NC}    - Create backup"
    echo ""
fi

echo -e "${CYAN} Documentation:${NC}"
echo -e "     Claude-Flow: ${BLUE}https://claude-flow.ruv.io${NC}"
echo -e "     Docker:      ${BLUE}https://docs.docker.com${NC}"
echo ""

echo -e "${CYAN} Pro Tips:${NC}"
echo -e "     • Use ${BLUE}lazydocker${NC} for easy container management"
echo -e "     • Create backups regularly: ${BLUE}make backup${NC}"
echo -e "     • Switch projects easily: ${BLUE}./switch-project.sh <path>${NC}"
echo ""

echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}Happy coding with Claude-Flow! ${NC}"
echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
