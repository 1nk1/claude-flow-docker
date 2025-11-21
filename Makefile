# ═══════════════════════════════════════════════════════════════
# Claude-Flow Docker Makefile
# Container management, CI/CD, testing, monitoring
# ═══════════════════════════════════════════════════════════════

.DEFAULT_GOAL := help
.PHONY: help setup start stop restart logs shell exec status clean backup restore test

# ═══════════════════════════════════════════════════════════════
# CONFIGURATION
# ═══════════════════════════════════════════════════════════════

CONTAINER_NAME := claude-flow-alpha
PROJECT_NAME := claude-flow-docker
COMPOSE_FILE := docker-compose.yml
ENV_FILE := .env

# Colors for output
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[0;33m
RED := \033[0;31m
PURPLE := \033[0;35m
CYAN := \033[0;36m
NC := \033[0m

# Emoji for visualization
ROCKET := 🚀
BEE := 🐝
GEAR := ⚙️
CHECK := ✅
CROSS := ❌
WARNING := ⚠️
EYES := 👀
PACKAGE := 📦
MEMORY := 💾
CHART := 📊
CLEAN := 🧹
BACKUP := 💿
RESTORE := 📥
TEST := 🧪
BUILD := 🏗️
LOCK := 🔒
UNLOCK := 🔓
FIRE := 🔥

# ═══════════════════════════════════════════════════════════════
# HELP & INFORMATION
# ═══════════════════════════════════════════════════════════════

help: ## Show this help
	@echo ""
	@echo "$(PURPLE)╔═══════════════════════════════════════════════════════════╗$(NC)"
	@echo "$(PURPLE)║  $(BEE) Claude-Flow Docker Management System$(NC)                 $(PURPLE)║$(NC)"
	@echo "$(PURPLE)╚═══════════════════════════════════════════════════════════╝$(NC)"
	@echo ""
	@echo "$(CYAN)📖 MAIN COMMANDS:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		grep -v "^#" | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-25s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(CYAN)💡 USAGE EXAMPLES:$(NC)"
	@echo "  make start                        - Start container"
	@echo "  make logs                         - View logs"
	@echo "  make shell                        - Enter container"
	@echo "  make swarm TASK=\"build API\"       - Run swarm task"
	@echo "  make backup                       - Create backup"
	@echo "  make test-all                     - Full testing"
	@echo ""
	@echo "$(CYAN)🔗 QUICK LINKS:$(NC)"
	@echo "  LazyDocker:    lazydocker"
	@echo "  Container IP:  make ip"
	@echo "  Full Status:   make info"
	@echo ""

version: ## Show versions of all components
	@echo "$(BLUE)$(PACKAGE) Component Versions:$(NC)"
	@echo "  Docker:        $$(docker --version | cut -d' ' -f3 | tr -d ',')"
	@echo "  Docker Compose: $$(docker-compose --version | cut -d' ' -f4 | tr -d ',')"
	@echo "  Node.js:       $$(docker exec $(CONTAINER_NAME) node --version 2>/dev/null || echo 'N/A')"
	@echo "  NPM:           $$(docker exec $(CONTAINER_NAME) npm --version 2>/dev/null || echo 'N/A')"
	@echo "  Claude-Flow:   $$(docker exec $(CONTAINER_NAME) npx claude-flow@alpha --version 2>/dev/null | head -1 || echo 'N/A')"
	@echo ""

# ═══════════════════════════════════════════════════════════════
# SETUP & INITIALIZATION
# ═══════════════════════════════════════════════════════════════

setup: ## Initial project setup
	@echo "$(BLUE)$(GEAR) Setting up Claude-Flow Docker...$(NC)"
	@if [ ! -f $(ENV_FILE) ]; then \
		echo "$(YELLOW)$(WARNING) .env not found, copying from .env.example$(NC)"; \
		cp .env.example .env; \
	fi
	@chmod +x scripts/*.sh docker-entrypoint.sh tests/*.sh docker/*.sh 2>/dev/null || true
	@echo "$(GREEN)$(CHECK) Setup complete!$(NC)"
	@echo ""
	@echo "$(CYAN)Next steps:$(NC)"
	@echo "  1. Edit .env and specify project paths"
	@echo "  2. Run: make build"
	@echo "  3. Run: make start"
	@echo ""

check-env: ## Check .env file
	@echo "$(BLUE)$(EYES) Checking environment...$(NC)"
	@if [ ! -f $(ENV_FILE) ]; then \
		echo "$(RED)$(CROSS) .env file not found!$(NC)"; \
		echo "Run: make setup"; \
		exit 1; \
	fi
	@echo "$(GREEN)$(CHECK) .env file exists$(NC)"
	@echo ""
	@echo "$(CYAN)Current configuration:$(NC)"
	@cat $(ENV_FILE) | grep -v '^#' | grep -v '^$$'
	@echo ""

validate: check-env ## Validate docker-compose configuration
	@echo "$(BLUE)$(GEAR) Validating docker-compose configuration...$(NC)"
	@docker-compose config --quiet && echo "$(GREEN)$(CHECK) Configuration is valid$(NC)" || echo "$(RED)$(CROSS) Configuration has errors$(NC)"

# ═══════════════════════════════════════════════════════════════
# CONTAINER LIFECYCLE
# ═══════════════════════════════════════════════════════════════

build: ## Build Docker image
	@echo "$(BLUE)$(BUILD) Building Docker image...$(NC)"
	@docker-compose build --no-cache
	@echo "$(GREEN)$(CHECK) Build complete$(NC)"

build-fast: ## Fast build (with cache)
	@echo "$(BLUE)$(BUILD) Fast building Docker image...$(NC)"
	@docker-compose build
	@echo "$(GREEN)$(CHECK) Build complete$(NC)"

start: ## Start container
	@echo "$(BLUE)$(ROCKET) Starting Claude-Flow...$(NC)"
	@docker-compose up -d
	@sleep 2
	@echo "$(GREEN)$(CHECK) Claude-Flow started$(NC)"
	@make status

stop: ## Stop container
	@echo "$(YELLOW)🛑 Stopping Claude-Flow...$(NC)"
	@docker-compose stop
	@echo "$(GREEN)$(CHECK) Claude-Flow stopped$(NC)"

restart: stop start ## Restart container

kill: ## Force kill container
	@echo "$(RED)$(FIRE) Force killing Claude-Flow...$(NC)"
	@docker-compose kill
	@echo "$(GREEN)$(CHECK) Killed$(NC)"

# ═══════════════════════════════════════════════════════════════
# LOGS & MONITORING
# ═══════════════════════════════════════════════════════════════

logs: ## View container logs (live)
	@docker-compose logs -f

logs-app: ## View application logs (live)
	@echo "$(BLUE)📊 Following application logs...$(NC)"
	@docker exec $(CONTAINER_NAME) tail -f /workspace/logs/claude-flow.log

logs-tail: ## Last 100 lines of container logs
	@docker logs $(CONTAINER_NAME) --tail 100

logs-app-tail: ## Last 100 lines of application logs
	@docker exec $(CONTAINER_NAME) tail -n 100 /workspace/logs/claude-flow.log

logs-error: ## Only errors in logs
	@echo "$(BLUE)🔍 Searching for errors...$(NC)"
	@docker exec $(CONTAINER_NAME) grep -E "\[ERROR\]|\[FATAL\]" /workspace/logs/claude-flow.log || echo "$(GREEN)No errors found$(NC)"

logs-warn: ## Only warnings in logs
	@echo "$(BLUE)🔍 Searching for warnings...$(NC)"
	@docker exec $(CONTAINER_NAME) grep "\[WARN\]" /workspace/logs/claude-flow.log || echo "$(GREEN)No warnings found$(NC)"

logs-mcp: ## MCP events only
	@echo "$(BLUE)🔍 MCP Events...$(NC)"
	@docker exec $(CONTAINER_NAME) grep "\[MCP\]" /workspace/logs/claude-flow.log || echo "$(YELLOW)No MCP events found$(NC)"

logs-stats: ## Log statistics
	@echo "$(BLUE)📊 Log Statistics...$(NC)"
	@docker exec $(CONTAINER_NAME) bash -c "source /workspace/lib/logger.sh && log_stats"

logs-viewer: ## Interactive log viewer
	@./scripts/view-logs.sh

logs-save: ## Save logs to file
	@mkdir -p logs
	@echo "$(BLUE)$(MEMORY) Saving logs to logs/claude-flow-$$(date +%Y%m%d-%H%M%S).log$(NC)"
	@docker logs $(CONTAINER_NAME) > logs/claude-flow-$$(date +%Y%m%d-%H%M%S).log
	@echo "$(GREEN)$(CHECK) Logs saved$(NC)"

watch: ## Monitor container (watch)
	@watch -n 2 'docker stats $(CONTAINER_NAME) --no-stream'

agents: ## View active agents with colors and status
	@echo "$(BLUE)🤖 Active Agents...$(NC)"
	@docker exec $(CONTAINER_NAME) bash -c "source /workspace/lib/agent-logger.sh && show_active_agents"

agents-logs: ## View agent activity logs (live)
	@echo "$(BLUE)🤖 Following agent logs...$(NC)"
	@docker exec $(CONTAINER_NAME) tail -f /workspace/logs/agents.log

agents-tail: ## Last 50 lines of agent logs
	@docker exec $(CONTAINER_NAME) tail -n 50 /workspace/logs/agents.log

test-agents: ## Test REAL agent workflows (not demo)
	@echo "$(BLUE)🚀 Testing real agent workflows...$(NC)"
	@./test-real-agents.sh

demo-agents: ## Run agent visualization demo
	@echo "$(BLUE)🎨 Running agent demo...$(NC)"
	@./demo-agents.sh

cf-memory: ## View claude-flow memory stats
	@echo "$(PURPLE)💾 Claude-Flow Memory Statistics...$(NC)"
	@docker exec $(CONTAINER_NAME) bash /workspace/lib/claude-flow-wrapper.sh memory stats

cf-hive: ## Initialize hive-mind system
	@echo "$(YELLOW)🐝 Initializing Hive-Mind...$(NC)"
	@docker exec $(CONTAINER_NAME) bash /workspace/lib/claude-flow-wrapper.sh hive-mind init

cf-query: ## Query memory (usage: make cf-query Q="search term")
	@docker exec $(CONTAINER_NAME) bash /workspace/lib/claude-flow-wrapper.sh memory query "$(Q)"

stats: ## Resource usage statistics
	@docker stats $(CONTAINER_NAME) --no-stream

top: ## Processes inside container
	@docker top $(CONTAINER_NAME)

# ═══════════════════════════════════════════════════════════════
# SHELL & EXECUTION
# ═══════════════════════════════════════════════════════════════

shell: ## Interactive shell in container
	@echo "$(CYAN)$(ROCKET) Entering container shell...$(NC)"
	@docker exec -it $(CONTAINER_NAME) sh

bash: ## Bash shell (if available)
	@docker exec -it $(CONTAINER_NAME) bash || docker exec -it $(CONTAINER_NAME) sh

exec: ## Execute command (make exec CMD="node --version")
	@if [ -z "$(CMD)" ]; then \
		echo "$(RED)$(CROSS) Usage: make exec CMD=\"your command\"$(NC)"; \
		exit 1; \
	fi
	@docker exec -it $(CONTAINER_NAME) sh -c "$(CMD)"

root: ## Shell as root user
	@docker exec -it -u root $(CONTAINER_NAME) sh

# ═══════════════════════════════════════════════════════════════
# STATUS & INFORMATION
# ═══════════════════════════════════════════════════════════════

status: ## Container status
	@echo "$(BLUE)$(CHART) Container Status:$(NC)"
	@docker-compose ps
	@echo ""

ps: status ## Alias for status

info: ## Full system information
	@echo "$(PURPLE)╔═══════════════════════════════════════════════════════════╗$(NC)"
	@echo "$(PURPLE)║  $(BEE) Claude-Flow System Information$(NC)                        $(PURPLE)║$(NC)"
	@echo "$(PURPLE)╚═══════════════════════════════════════════════════════════╝$(NC)"
	@echo ""
	@make version
	@echo "$(BLUE)$(CHART) Container Status:$(NC)"
	@docker-compose ps
	@echo ""
	@echo "$(BLUE)$(MEMORY) Volume Information:$(NC)"
	@docker volume ls | grep claude-flow
	@echo ""
	@echo "$(BLUE)$(PACKAGE) Image Information:$(NC)"
	@docker images | grep claude-flow || echo "  No images found"
	@echo ""
	@echo "$(BLUE)🌐 Network Information:$(NC)"
	@docker network ls | grep claude-flow || echo "  No networks found"
	@echo ""

ip: ## Show container IP address
	@echo "$(CYAN)Container IP:$(NC) $$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(CONTAINER_NAME))"

inspect: ## Detailed container information (JSON)
	@docker inspect $(CONTAINER_NAME)

# ═══════════════════════════════════════════════════════════════
# CLAUDE-FLOW SPECIFIC
# ═══════════════════════════════════════════════════════════════

cf-status: ## Claude-Flow status (hive-mind + memory)
	@echo "$(BLUE)$(BEE) Hive-Mind Status:$(NC)"
	@docker exec $(CONTAINER_NAME) npx claude-flow@alpha hive-mind status 2>/dev/null || echo "  No active sessions"
	@echo ""
	@echo "$(BLUE)$(MEMORY) Memory Status:$(NC)"
	@docker exec $(CONTAINER_NAME) npx claude-flow@alpha memory stats 2>/dev/null || echo "  No memory data"
	@echo ""

cf-init: ## Initialize Claude-Flow in project
	@echo "$(BLUE)$(PACKAGE) Initializing Claude-Flow...$(NC)"
	@docker exec $(CONTAINER_NAME) sh -c "cd /workspace/project && npx claude-flow@alpha init --force"
	@echo "$(GREEN)$(CHECK) Initialized$(NC)"

hive-spawn: ## Spawn hive-mind (make hive-spawn TASK="build API")
	@if [ -z "$(TASK)" ]; then \
		echo "$(RED)$(CROSS) Usage: make hive-spawn TASK=\"your task\"$(NC)"; \
		exit 1; \
	fi
	@echo "$(BLUE)$(BEE) Spawning hive-mind: $(TASK)$(NC)"
	@docker exec -it $(CONTAINER_NAME) npx claude-flow@alpha hive-mind spawn "$(TASK)" --claude

hive-list: ## List active hive-mind sessions
	@docker exec $(CONTAINER_NAME) npx claude-flow@alpha hive-mind list

hive-kill: ## Kill all hive-mind sessions
	@echo "$(RED)$(FIRE) Killing all hive-mind sessions...$(NC)"
	@docker exec $(CONTAINER_NAME) npx claude-flow@alpha hive-mind kill-all
	@echo "$(GREEN)$(CHECK) All sessions killed$(NC)"

swarm: ## Run swarm task (make swarm TASK="your task")
	@if [ -z "$(TASK)" ]; then \
		echo "$(RED)$(CROSS) Usage: make swarm TASK=\"your task\"$(NC)"; \
		exit 1; \
	fi
	@echo "$(BLUE)🌊 Running swarm: $(TASK)$(NC)"
	@docker exec -it $(CONTAINER_NAME) npx claude-flow@alpha swarm "$(TASK)" --claude

memory-stats: ## Claude-Flow memory statistics
	@docker exec $(CONTAINER_NAME) npx claude-flow@alpha memory stats

memory-query: ## Query memory (make memory-query Q="auth")
	@if [ -z "$(Q)" ]; then \
		echo "$(RED)$(CROSS) Usage: make memory-query Q=\"search term\"$(NC)"; \
		exit 1; \
	fi
	@docker exec $(CONTAINER_NAME) npx claude-flow@alpha memory query "$(Q)"

memory-clear: ## Clear memory (CAUTION!)
	@echo "$(RED)$(WARNING) This will clear all memory data!$(NC)"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		docker exec $(CONTAINER_NAME) npx claude-flow@alpha memory clear; \
		echo "$(GREEN)$(CHECK) Memory cleared$(NC)"; \
	else \
		echo "$(YELLOW)Cancelled$(NC)"; \
	fi

# ═══════════════════════════════════════════════════════════════
# BACKUP & RESTORE
# ═══════════════════════════════════════════════════════════════

backup: ## Create backup of all volumes
	@echo "$(BLUE)$(BACKUP) Creating backup...$(NC)"
	@mkdir -p backups
	@echo "  Backing up swarm data..."
	@docker run --rm \
		-v claude-flow_claude-flow-swarm:/data \
		-v $$(pwd)/backups:/backup \
		alpine tar czf /backup/swarm-$$(date +%Y%m%d-%H%M%S).tar.gz -C /data .
	@echo "  Backing up hive-mind data..."
	@docker run --rm \
		-v claude-flow_claude-flow-hive:/data \
		-v $$(pwd)/backups:/backup \
		alpine tar czf /backup/hive-$$(date +%Y%m%d-%H%M%S).tar.gz -C /data .
	@echo "  Backing up memory data..."
	@docker run --rm \
		-v claude-flow_claude-flow-memory:/data \
		-v $$(pwd)/backups:/backup \
		alpine tar czf /backup/memory-$$(date +%Y%m%d-%H%M%S).tar.gz -C /data .
	@echo "$(GREEN)$(CHECK) Backup created in ./backups/$(NC)"
	@ls -lh backups/ | tail -3

backup-list: ## List all backups
	@echo "$(BLUE)$(BACKUP) Available backups:$(NC)"
	@ls -lh backups/ 2>/dev/null || echo "No backups found"

restore: ## Restore from backup (make restore BACKUP=swarm-20231016-120000.tar.gz)
	@if [ -z "$(BACKUP)" ]; then \
		echo "$(RED)$(CROSS) Usage: make restore BACKUP=filename.tar.gz$(NC)"; \
		echo ""; \
		echo "Available backups:"; \
		ls backups/ 2>/dev/null || echo "No backups found"; \
		exit 1; \
	fi
	@if [ ! -f "backups/$(BACKUP)" ]; then \
		echo "$(RED)$(CROSS) Backup file not found: backups/$(BACKUP)$(NC)"; \
		exit 1; \
	fi
	@echo "$(YELLOW)$(WARNING) This will overwrite current data!$(NC)"
	@read -p "Continue? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		echo "$(BLUE)$(RESTORE) Restoring from $(BACKUP)...$(NC)"; \
		VOLUME_NAME=$$(echo "$(BACKUP)" | cut -d'-' -f1); \
		docker run --rm \
			-v claude-flow_claude-flow-$$VOLUME_NAME:/data \
			-v $$(pwd)/backups:/backup \
			alpine sh -c "rm -rf /data/* && tar xzf /backup/$(BACKUP) -C /data"; \
		echo "$(GREEN)$(CHECK) Restore complete$(NC)"; \
	else \
		echo "$(YELLOW)Cancelled$(NC)"; \
	fi

# ═══════════════════════════════════════════════════════════════
# CLEANUP & MAINTENANCE
# ═══════════════════════════════════════════════════════════════

clean: ## Stop and remove containers
	@echo "$(BLUE)$(CLEAN) Cleaning up containers...$(NC)"
	@docker-compose down
	@echo "$(GREEN)$(CHECK) Cleanup complete$(NC)"

clean-images: ## Remove unused images
	@echo "$(BLUE)$(CLEAN) Removing unused images...$(NC)"
	@docker image prune -f
	@echo "$(GREEN)$(CHECK) Images cleaned$(NC)"

clean-volumes: ## Remove volumes (DELETES ALL DATA!)
	@echo "$(RED)$(WARNING) This will DELETE ALL Claude-Flow data!$(NC)"
	@echo "$(YELLOW)Volumes to be removed:$(NC)"
	@docker volume ls | grep claude-flow
	@echo ""
	@read -p "Are you ABSOLUTELY sure? Type 'yes' to confirm: " confirm; \
	if [ "$$confirm" = "yes" ]; then \
		docker-compose down -v; \
		echo "$(GREEN)$(CHECK) All volumes removed$(NC)"; \
	else \
		echo "$(YELLOW)Cancelled (you must type 'yes')$(NC)"; \
	fi

clean-all: clean clean-images ## Full cleanup (containers + images)
	@echo "$(GREEN)$(CHECK) Full cleanup complete$(NC)"

prune: ## Docker system prune (free space)
	@echo "$(BLUE)$(CLEAN) Running Docker system prune...$(NC)"
	@docker system prune -f
	@echo "$(GREEN)$(CHECK) System pruned$(NC)"

reset: clean-volumes build start ## Full reset (recreate everything)
	@echo "$(GREEN)$(CHECK) System reset complete$(NC)"

# ═══════════════════════════════════════════════════════════════
# DEVELOPMENT & TESTING
# ═══════════════════════════════════════════════════════════════

dev: ## Development mode (logs + watch)
	@echo "$(CYAN)$(EYES) Development mode - watching logs...$(NC)"
	@docker-compose logs -f

test: ## Basic testing
	@echo "$(BLUE)$(TEST) Running basic tests...$(NC)"
	@echo "  Testing Node.js..."
	@docker exec $(CONTAINER_NAME) node --version
	@echo "  Testing NPM..."
	@docker exec $(CONTAINER_NAME) npm --version
	@echo "  Testing Claude-Flow..."
	@docker exec $(CONTAINER_NAME) npx claude-flow@alpha --version
	@echo "$(GREEN)$(CHECK) All tests passed$(NC)"

test-memory: ## Test memory system
	@echo "$(BLUE)$(TEST) Testing memory system...$(NC)"
	@docker exec $(CONTAINER_NAME) npx claude-flow@alpha memory stats
	@docker exec $(CONTAINER_NAME) sh -c "ls -lh /workspace/.swarm/"
	@echo "$(GREEN)$(CHECK) Memory system OK$(NC)"

test-mcp: ## Test MCP servers
	@echo "$(BLUE)$(TEST) Testing MCP servers...$(NC)"
	@docker exec $(CONTAINER_NAME) cat /workspace/.claude/settings.json
	@echo "$(GREEN)$(CHECK) MCP configuration OK$(NC)"

test-all: test test-memory test-mcp ## Full testing suite
	@echo "$(GREEN)$(CHECK) All tests completed$(NC)"

lint-dockerfile: ## Lint Dockerfile (requires hadolint)
	@if command -v hadolint >/dev/null 2>&1; then \
		echo "$(BLUE)$(TEST) Linting Dockerfile...$(NC)"; \
		hadolint Dockerfile; \
		echo "$(GREEN)$(CHECK) Dockerfile lint OK$(NC)"; \
	else \
		echo "$(YELLOW)$(WARNING) hadolint not installed. Install: brew install hadolint$(NC)"; \
	fi

# ═══════════════════════════════════════════════════════════════
# PACKAGE MANAGEMENT
# ═══════════════════════════════════════════════════════════════

npm-install: ## Install npm package (make npm-install PKG="lodash")
	@if [ -z "$(PKG)" ]; then \
		echo "$(RED)$(CROSS) Usage: make npm-install PKG=\"package-name\"$(NC)"; \
		exit 1; \
	fi
	@echo "$(BLUE)$(PACKAGE) Installing $(PKG)...$(NC)"
	@docker exec $(CONTAINER_NAME) sh -c "cd /workspace/project && npm install $(PKG)"
	@echo "$(GREEN)$(CHECK) Package installed$(NC)"

npm-update: ## Update all npm packages in project
	@echo "$(BLUE)$(PACKAGE) Updating npm packages...$(NC)"
	@docker exec $(CONTAINER_NAME) sh -c "cd /workspace/project && npm update"
	@echo "$(GREEN)$(CHECK) Packages updated$(NC)"

npm-outdated: ## Check outdated packages
	@docker exec $(CONTAINER_NAME) sh -c "cd /workspace/project && npm outdated"

npm-audit: ## Audit npm package security
	@echo "$(BLUE)$(LOCK) Running npm audit...$(NC)"
	@docker exec $(CONTAINER_NAME) sh -c "cd /workspace/project && npm audit"

npm-audit-fix: ## Auto-fix npm vulnerabilities
	@echo "$(BLUE)$(LOCK) Fixing npm vulnerabilities...$(NC)"
	@docker exec $(CONTAINER_NAME) sh -c "cd /workspace/project && npm audit fix"
	@echo "$(GREEN)$(CHECK) Vulnerabilities fixed$(NC)"

# ═══════════════════════════════════════════════════════════════
# CI/CD HELPERS
# ═══════════════════════════════════════════════════════════════

ci-build: ## CI: Build image
	@docker-compose build --pull --no-cache

ci-test: ## CI: Run tests
	@docker-compose up -d
	@sleep 5
	@make test-all
	@docker-compose down

ci-deploy: ## CI: Deploy (example)
	@echo "$(BLUE)$(ROCKET) Deploying to production...$(NC)"
	@docker-compose -f docker-compose.prod.yml up -d
	@echo "$(GREEN)$(CHECK) Deployed$(NC)"

# ═══════════════════════════════════════════════════════════════
# UTILITIES
# ═══════════════════════════════════════════════════════════════

port-check: ## Check port availability
	@echo "$(BLUE)Checking ports...$(NC)"
	@echo "  Port 8811 (MCP): $$(lsof -i :8811 | grep LISTEN || echo 'FREE')"
	@echo "  Port 3000 (Web): $$(lsof -i :3000 | grep LISTEN || echo 'FREE')"

disk-usage: ## Docker disk usage
	@echo "$(BLUE)$(MEMORY) Docker disk usage:$(NC)"
	@docker system df

volume-inspect: ## Inspect volumes
	@echo "$(BLUE)$(MEMORY) Volume details:$(NC)"
	@docker volume ls | grep claude-flow | while read driver name; do \
		echo ""; \
		echo "Volume: $$name"; \
		docker volume inspect $$name | grep -A 10 "Mountpoint"; \
	done

config-show: ## Show current docker-compose config
	@docker-compose config

env-show: ## Show environment variables
	@docker exec $(CONTAINER_NAME) env | sort

update-deps: ## Update all system dependencies
	@echo "$(BLUE)$(PACKAGE) Updating system dependencies...$(NC)"
	@docker exec -u root $(CONTAINER_NAME) apk update
	@docker exec -u root $(CONTAINER_NAME) apk upgrade
	@echo "$(GREEN)$(CHECK) Dependencies updated$(NC)"

# ═══════════════════════════════════════════════════════════════
# QUICK ALIASES
# ═══════════════════════════════════════════════════════════════

up: start       ## Alias: start
down: stop      ## Alias: stop
sh: shell       ## Alias: shell
log: logs       ## Alias: logs
st: status      ## Alias: status
re: restart     ## Alias: restart
cf: cf-status   ## Alias: cf-status

# ═══════════════════════════════════════════════════════════════
# DOCUMENTATION
# ═══════════════════════════════════════════════════════════════

docs: ## Open documentation
	@echo "$(CYAN)📚 Opening documentation...$(NC)"
	@echo ""
	@echo "📖 Claude-Flow Documentation:"
	@echo "   https://claude-flow.ruv.io"
	@echo ""
	@echo "📖 Appium Documentation:"
	@echo "   https://appium.io/docs"
	@echo ""
	@echo "📖 WebDriverIO Documentation:"
	@echo "   https://webdriver.io"
	@echo ""

readme: ## Generate README.md
	@echo "# Claude-Flow Docker" > README.md
	@echo "" >> README.md
	@echo "Docker container for Claude-Flow with full configuration and automation." >> README.md
	@echo "" >> README.md
	@echo "## Quick Start" >> README.md
	@echo "" >> README.md
	@echo "\`\`\`bash" >> README.md
	@echo "make setup   # Initial setup" >> README.md
	@echo "make build   # Build image" >> README.md
	@echo "make start   # Start container" >> README.md
	@echo "make info    # System information" >> README.md
	@echo "\`\`\`" >> README.md
	@echo "" >> README.md
	@echo "## Commands" >> README.md
	@echo "" >> README.md
	@make help >> README.md
	@echo "$(GREEN)$(CHECK) README.md created$(NC)"

# ═══════════════════════════════════════════════════════════════
# SPECIAL TARGETS
# ═══════════════════════════════════════════════════════════════

.SILENT: help version
