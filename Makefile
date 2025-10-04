# Makefile для Claude-Flow Docker
# Упрощает управление контейнерами

.PHONY: help setup start stop restart logs shell exec status clean backup restore test

# Цвета для вывода
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[0;33m
RED := \033[0;31m
NC := \033[0m # No Color

help: ## Показать эту справку
	@echo "$(BLUE)🐝 Claude-Flow Docker Commands$(NC)"
	@echo "================================"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "$(GREEN)%-20s$(NC) %s\n", $$1, $$2}'

setup: ## Первоначальная настройка проекта
	@echo "$(BLUE)🔧 Setting up Claude-Flow Docker...$(NC)"
	@chmod +x *.sh docker-entrypoint.sh
	@./setup.sh

start: ## Запустить контейнер
	@echo "$(BLUE)🚀 Starting Claude-Flow...$(NC)"
	@./cf-start.sh

stop: ## Остановить контейнер
	@echo "$(YELLOW)🛑 Stopping Claude-Flow...$(NC)"
	@./cf-stop.sh

restart: stop start ## Перезапустить контейнер
	@echo "$(GREEN)♻️  Claude-Flow restarted$(NC)"

logs: ## Просмотр логов
	@./cf-logs.sh

shell: ## Интерактивный shell в контейнере
	@./cf-shell.sh

exec: ## Выполнить команду в контейнере (make exec CMD="claude-flow --help")
	@./cf-exec.sh $(CMD)

status: ## Проверить статус контейнера и hive-mind
	@echo "$(BLUE)📊 Container Status:$(NC)"
	@docker-compose ps
	@echo ""
	@echo "$(BLUE)🐝 Hive-Mind Status:$(NC)"
	@./cf-exec.sh claude-flow hive-mind status || echo "No active hive-mind sessions"
	@echo ""
	@echo "$(BLUE)💾 Memory Status:$(NC)"
	@./cf-exec.sh claude-flow memory stats || echo "No memory data"

clean: ## Остановить и удалить контейнеры
	@echo "$(RED)🧹 Cleaning up containers...$(NC)"
	@docker-compose down
	@echo "$(GREEN)✅ Cleanup complete$(NC)"

clean-all: ## Удалить контейнеры и volumes (УДАЛИТ ВСЕ ДАННЫЕ!)
	@echo "$(RED)⚠️  WARNING: This will delete all Claude-Flow data!$(NC)"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		docker-compose down -v; \
		echo "$(GREEN)✅ All data removed$(NC)"; \
	else \
		echo "$(YELLOW)Cancelled$(NC)"; \
	fi

backup: ## Создать backup volumes
	@echo "$(BLUE)💾 Creating backup...$(NC)"
	@mkdir -p backups
	@docker run --rm \
		-v claude-flow-swarm:/data \
		-v $$(pwd)/backups:/backup \
		alpine tar czf /backup/swarm-$$(date +%Y%m%d-%H%M%S).tar.gz /data
	@docker run --rm \
		-v claude-flow-hive:/data \
		-v $$(pwd)/backups:/backup \
		alpine tar czf /backup/hive-$$(date +%Y%m%d-%H%M%S).tar.gz /data
	@echo "$(GREEN)✅ Backup created in ./backups/$(NC)"

restore: ## Восстановить из backup (make restore BACKUP=file.tar.gz)
	@if [ -z "$(BACKUP)" ]; then \
		echo "$(RED)❌ Please specify backup file: make restore BACKUP=file.tar.gz$(NC)"; \
		exit 1; \
	fi
	@echo "$(BLUE)📥 Restoring from $(BACKUP)...$(NC)"
	@docker run --rm \
		-v claude-flow-swarm:/data \
		-v $$(pwd)/backups:/backup \
		alpine tar xzf /backup/$(BACKUP) -C /
	@echo "$(GREEN)✅ Restore complete$(NC)"

test: ## Тест работоспособности
	@echo "$(BLUE)🧪 Testing Claude-Flow...$(NC)"
	@./cf-exec.sh claude-flow --version
	@./cf-exec.sh node --version
	@./cf-exec.sh npm --version
	@echo "$(GREEN)✅ All tests passed$(NC)"

build: ## Rebuild Docker образа
	@echo "$(BLUE)🏗️  Building Docker image...$(NC)"
	@docker-compose build --no-cache
	@echo "$(GREEN)✅ Build complete$(NC)"

init-project: ## Инициализировать Claude-Flow в проекте
	@echo "$(BLUE)📦 Initializing Claude-Flow in project...$(NC)"
	@./cf-exec.sh claude-flow init --force
	@echo "$(GREEN)✅ Project initialized$(NC)"

hive-spawn: ## Создать новый hive-mind (make hive-spawn TASK="build API")
	@if [ -z "$(TASK)" ]; then \
		echo "$(RED)❌ Please specify task: make hive-spawn TASK=\"your task\"$(NC)"; \
		exit 1; \
	fi
	@echo "$(BLUE)🐝 Spawning hive-mind for: $(TASK)$(NC)"
	@./cf-exec.sh claude-flow hive-mind spawn "$(TASK)" --claude

swarm: ## Быстрая swarm команда (make swarm TASK="build feature")
	@if [ -z "$(TASK)" ]; then \
		echo "$(RED)❌ Please specify task: make swarm TASK=\"your task\"$(NC)"; \
		exit 1; \
	fi
	@echo "$(BLUE)🌊 Running swarm: $(TASK)$(NC)"
	@./cf-exec.sh claude-flow swarm "$(TASK)" --claude

memory-stats: ## Показать статистику памяти
	@./cf-exec.sh claude-flow memory stats

memory-query: ## Поиск в памяти (make memory-query Q="auth")
	@if [ -z "$(Q)" ]; then \
		echo "$(RED)❌ Please specify query: make memory-query Q=\"search term\"$(NC)"; \
		exit 1; \
	fi
	@./cf-exec.sh claude-flow memory query "$(Q)"

install-package: ## Установить npm пакет в контейнер (make install-package PKG="lodash")
	@if [ -z "$(PKG)" ]; then \
		echo "$(RED)❌ Please specify package: make install-package PKG=\"package-name\"$(NC)"; \
		exit 1; \
	fi
	@echo "$(BLUE)📦 Installing $(PKG)...$(NC)"
	@./cf-exec.sh npm install $(PKG)
	@echo "$(GREEN)✅ Package installed$(NC)"

# Aliases для удобства
run: start
down: stop
ps: status
sh: shell
