# Quick Reference - Real Agent Usage

## One-Line Commands

### Memory Operations (Real Agents)
```bash
# Store memory
docker exec claude-flow-alpha claude-flow memory store "key" "title" '{"data":"value"}'

# Query memory
docker exec claude-flow-alpha claude-flow memory query "search term"

# List all
docker exec claude-flow-alpha claude-flow memory list

# Stats
make cf-memory
```

### Hive-Mind (Coordinator Agents)
```bash
# Initialize
make cf-hive

# Status
docker exec claude-flow-alpha claude-flow hive-mind status

# Wizard (interactive)
docker exec claude-flow-alpha claude-flow hive-mind wizard
```

### Agent Monitoring
```bash
# Watch live (best for lazydocker)
docker logs -f claude-flow-alpha

# Active agents dashboard
make agents

# Agent activity logs
make agents-logs

# Last 50 actions
make agents-tail
```

### Testing
```bash
# Demo (8 colored agents)
make demo-agents

# Real workflow test
make test-agents
```

## lazydocker (BEST WAY!)

```bash
# Terminal 1
lazydocker
# Navigate to claude-flow-alpha
# Press 'l' for logs

# Terminal 2 - run commands and watch agents appear!
make cf-memory
make test-agents
```

## Agent Colors

- 🎯 **Cyan #0** - Coordinator
- 🔍 **Pink #1** - Researcher
- 💻 **Yellow #2** - Coder
- 👀 **Green #3** - Reviewer
- 🧪 **Purple #4** - Tester
- ⚡ **Orange #5** - Optimizer
- 🎨 **Blue #6** - Designer
- 📋 **Pink #7** - Planner

## Quick Examples

### Example 1: Store & Query
```bash
# Terminal 1: Watch agents
make agents-logs

# Terminal 2: Store
docker exec claude-flow-alpha claude-flow memory store \
  "api-task" "REST API" '{"status":"in-progress"}'

# Query
docker exec claude-flow-alpha claude-flow memory query "API"
```

### Example 2: Full Workflow
```bash
# Initialize hive
make cf-hive

# Check status
docker exec claude-flow-alpha claude-flow hive-mind status

# Store project info
docker exec claude-flow-alpha claude-flow memory store \
  "project" "My App" '{"version":"1.0.0"}'

# Query it
make cf-query Q="My App"
```

## Troubleshooting

```bash
# Check container
docker ps | grep claude-flow

# Check claude-flow version
docker exec claude-flow-alpha claude-flow --version

# Test agent logger
docker exec claude-flow-alpha bash -c \
  'source /workspace/lib/agent-logger.sh && log_agent_start 0 "Test" "coordinator"'

# View logs
docker logs claude-flow-alpha --tail 100
```

## Full Documentation

- `REAL_USAGE.md` - Complete real usage guide
- `AGENT_VISUALIZATION.md` - Agent system details
- `QUICKSTART.md` - Getting started
- `TROUBLESHOOTING.md` - Problem solving
