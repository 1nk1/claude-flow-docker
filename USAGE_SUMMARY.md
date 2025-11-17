# 🚀 Как Пользоваться РЕАЛЬНО (Не Demo)

## ✅ Всё Работает!

Container: **RUNNING** (claude-flow-alpha)
Claude-Flow: **v2.7.35**  
Agent Visualization: **8 colored agents**
Memory System: **ReasoningBank (SQLite + embeddings)**

## Быстрый Старт

### 1. Мониторинг Агентов в Реальном Времени

**ЛУЧШИЙ СПОСОБ - lazydocker:**
```bash
# Терминал 1
lazydocker
# Навигация к claude-flow-alpha
# Нажать 'l' для логов

# Терминал 2 - запускать команды
make test-agents
make cf-memory
```

**Альтернатива - логи напрямую:**
```bash
# Следить за агентами
make agents-logs

# Статус активных агентов  
make agents

# Последние 50 действий
make agents-tail
```

### 2. Реальные Команды (НЕ Demo!)

```bash
# Демо (только для теста)
make demo-agents

# РЕАЛЬНЫЕ workflow тесты
make test-agents

# Memory статистика
make cf-memory

# Инициализация hive-mind
make cf-hive

# Query memory
make cf-query Q="search term"
```

## Реальные Примеры

### Пример 1: Работа с Memory

```bash
# Сохранить память (запускает storage agents)
docker exec claude-flow-alpha claude-flow memory store \
  "api-project" \
  "REST API Development" \
  '{"endpoints":["users","auth"],"status":"active"}'

# Запросить память (запускает retrieval agents)
docker exec claude-flow-alpha claude-flow memory query "API"

# Просмотр статистики
make cf-memory
```

### Пример 2: Hive-Mind Координация

```bash
# Инициализация (создаёт coordinator agents)
make cf-hive

# Проверка статуса
docker exec claude-flow-alpha claude-flow hive-mind status

# Интерактивный wizard
docker exec claude-flow-alpha claude-flow hive-mind wizard
```

### Пример 3: Полный Workflow

```bash
# Терминал 1: Следить за агентами
make agents-logs

# Терминал 2: Команды
docker exec claude-flow-alpha claude-flow hive-mind init
docker exec claude-flow-alpha claude-flow memory store \
  "task-1" "Implement auth" '{"priority":"high"}'
docker exec claude-flow-alpha claude-flow memory query "auth"
```

## 8 Цветных Агентов

Каждый агент имеет:
- ✅ **Уникальный цвет** (256-color ANSI)
- ✅ **Иконку** (🎯🔍💻👀🧪⚡🎨📋)
- ✅ **Имя** (CoordinatorAgent, ResearchAgent, etc)
- ✅ **Специализацию** (coordinator, researcher, coder, etc)
- ✅ **Действия в реальном времени** (с деталями)

### Цвета:
- 🎯 **Cyan #0** - Coordinator (координатор)
- 🔍 **Pink #1** - Researcher (исследователь)
- 💻 **Yellow #2** - Coder (программист)
- 👀 **Green #3** - Reviewer (ревьювер)
- 🧪 **Purple #4** - Tester (тестировщик)
- ⚡ **Orange #5** - Optimizer (оптимизатор)
- 🎨 **Light Blue #6** - Designer (дизайнер)
- 📋 **Light Pink #7** - Planner (планировщик)

## Что Видно в Логах

### Real-time Agent Actions:
```
[38;5;51m #0[0m [38;5;240m14:30:15[0m [38;5;255mAnalyzing requirements[0m [2m│ Initial phase[0m
[38;5;213m #1[0m [38;5;240m14:30:16[0m [38;5;255mSearching docs[0m [2m│ Found 15 results[0m
[38;5;226m #2[0m [38;5;240m14:30:17[0m [38;5;255mImplementing auth[0m [2m│ Using JWT[0m
```

### Agent Status Dashboard:
```
🎯 Agent #0 CoordinatorAgent [coordinator]
   ├─ Status: ACTIVE
   └─ Coordinating team efforts
```

### Structured Logs:
```
[2025-11-17T14:30:15Z] AGENT_START | ID=0 | NAME=CoordinatorAgent | SPEC=coordinator
[2025-11-17T14:30:16Z] AGENT_ACTION | ID=0 | ACTION=Analyzing | DETAILS=Requirements
[2025-11-17T14:30:20Z] AGENT_COMPLETE | ID=0 | RESULT=Done
```

## Где Смотреть

### 1. lazydocker (Рекомендуется!)
- Визуальный интерфейс
- Цветные логи в реальном времени
- Удобная навигация

### 2. Docker Logs
```bash
docker logs -f claude-flow-alpha
```

### 3. Make Commands
```bash
make agents          # Статус агентов
make agents-logs     # Live логи
make agents-tail     # Последние действия
```

### 4. Agent Log Files
```bash
# Просмотр файла логов
docker exec claude-flow-alpha cat /workspace/logs/agents.log

# Поиск по агентам
docker exec claude-flow-alpha grep "Agent #2" /workspace/logs/agents.log

# Подсчёт агентов
docker exec claude-flow-alpha bash -c \
  "grep AGENT_START /workspace/logs/agents.log | wc -l"
```

## Это НЕ Demo!

❌ **Demo** - `./demo-agents.sh` - симулирует агентов для показа  
✅ **REAL** - `make test-agents` - запускает настоящие claude-flow команды  
✅ **REAL** - `make cf-memory` - ReasoningBank с embeddings  
✅ **REAL** - `make cf-hive` - Hive-Mind coordinator agents  
✅ **REAL** - Memory operations - SQLite database + semantic search

## Интеграция с Вашими Проектами

### Через Docker:
```bash
# Маппинг вашего проекта
export PROJECT_PATH=/path/to/your/project
docker-compose restart

# Использование
docker exec claude-flow-alpha bash -c \
  "cd /workspace/project && claude-flow memory stats"
```

### Через MCP (Claude Code):
```bash
# Копировать конфиг в проект
cp config/.claude/settings.json ~/your-project/.claude/

# Запустить Claude Code
cd ~/your-project
claude

# В Claude Code:
"Claude, using claude-flow MCP, store this memory: 'Task completed'"
```

## Документация

- `QUICK_REFERENCE.md` - Краткая справка команд
- `REAL_USAGE.md` - Полное руководство по использованию
- `AGENT_VISUALIZATION.md` - Детали системы агентов
- `TROUBLESHOOTING.md` - Решение проблем

## Полезные Команды

```bash
# Проверить контейнер
docker ps | grep claude-flow

# Версия claude-flow
docker exec claude-flow-alpha claude-flow --version

# Проверить агенты работают
make test-agents

# Проверить memory систему
make cf-memory

# Помощь
make help
```

## Всё Готово к Работе! ✅

- ✅ Container запущен без crash loops
- ✅ Claude-Flow v2.7.35 установлен
- ✅ ReasoningBank memory система работает
- ✅ MCP server готов к подключению
- ✅ 8 цветных агентов визуализируются
- ✅ Agent logger перехватывает команды
- ✅ Логи пишутся в /workspace/logs/agents.log
- ✅ lazydocker показывает агентов в реальном времени

**Используй РЕАЛЬНЫЕ команды, не demo!**
