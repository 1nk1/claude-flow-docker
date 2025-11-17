# Real Agent Usage Guide

How to use agent visualization with REAL workflows (not demo).

## Quick Start

### 1. Monitor Agents in Real-Time

**Terminal 1 - Watch agents:**
```bash
make agents-logs
```

**Terminal 2 - Run commands:**
```bash
docker exec claude-flow-alpha claude-flow memory store test "My task" '{"data":"value"}'
```

### 2. Using lazydocker (Best Way!)

```bash
lazydocker
```

1. Navigate to `claude-flow-alpha` container
2. Press `l` for logs
3. You'll see colored agents in real-time!
4. Run commands in another terminal to see agents spawn

## Real Command Examples

### Memory Operations (Shows ReasoningBank Agents)

```bash
# Store memory - shows storage agents
docker exec claude-flow-alpha claude-flow memory store \
  "project-context" \
  "API Development" \
  '{"endpoints":["users","auth"],"status":"in-progress"}'

# Query memory - shows retrieval agents
docker exec claude-flow-alpha claude-flow memory query "API"

# List memories
docker exec claude-flow-alpha claude-flow memory list
```

### Hive-Mind Workflows (Spawns Multiple Agents)

```bash
# Initialize hive-mind (coordinator agents)
docker exec claude-flow-alpha claude-flow hive-mind init

# Check status
docker exec claude-flow-alpha claude-flow hive-mind status

# Interactive wizard
docker exec claude-flow-alpha claude-flow hive-mind wizard
```

### Swarm Operations (Parallel Agent Execution)

Note: Swarm commands require Anthropic API key in .env

```bash
# Create swarm with --claude flag
docker exec claude-flow-alpha claude-flow swarm create \
  "analyze codebase structure" \
  --claude

# List active swarms
docker exec claude-flow-alpha claude-flow swarm list

# Get swarm status
docker exec claude-flow-alpha claude-flow swarm status <id>
```

## Agent Visualization Modes

### Mode 1: Live Logs (Colored Output)

```bash
# Follow agent activity
docker logs -f claude-flow-alpha
```

You'll see:
- 🎯 **Cyan #0** - Coordinator agents
- 🔍 **Pink #1** - Research agents
- 💻 **Yellow #2** - Coding agents
- 👀 **Green #3** - Review agents
- 🧪 **Purple #4** - Testing agents
- ⚡ **Orange #5** - Optimization agents
- 🎨 **Light Blue #6** - Design agents
- 📋 **Light Pink #7** - Planning agents

### Mode 2: Agent Status Dashboard

```bash
# View current active agents
make agents

# Or directly:
docker exec claude-flow-alpha bash -c \
  "source /workspace/lib/agent-logger.sh && show_active_agents"
```

### Mode 3: Log Analysis

```bash
# Last 50 agent actions
make agents-tail

# Search for specific agent
docker exec claude-flow-alpha grep "Agent #2" /workspace/logs/agents.log

# Count agent activities
docker exec claude-flow-alpha bash -c \
  "grep AGENT_START /workspace/logs/agents.log | wc -l"
```

## lazydocker Integration (RECOMMENDED!)

This is the BEST way to see agents in action:

### Setup:
```bash
# Install lazydocker if not installed
brew install lazydocker  # macOS
# or
curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash
```

### Usage:
```bash
# Terminal 1: Start lazydocker
lazydocker

# Navigate to claude-flow-alpha
# Press 'l' for logs
# You'll see colored agents in real-time!
```

### Terminal 2: Run commands
```bash
# Store some memories
docker exec claude-flow-alpha claude-flow memory store \
  "task-1" "Implement auth" '{"priority":"high"}'

docker exec claude-flow-alpha claude-flow memory store \
  "task-2" "Add tests" '{"priority":"medium"}'

# Query them
docker exec claude-flow-alpha claude-flow memory query "auth"
```

Watch lazydocker - you'll see agents appear and work!

## Real-World Example Workflow

### Scenario: Building REST API with Agent Monitoring

**Step 1: Initialize project memory**
```bash
docker exec claude-flow-alpha claude-flow memory store \
  "project-init" \
  "REST API Development" \
  '{
    "name": "user-service-api",
    "endpoints": ["users", "auth", "profiles"],
    "tech": "Node.js + Express",
    "started": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"
  }'
```

**Step 2: Store requirements**
```bash
docker exec claude-flow-alpha claude-flow memory store \
  "requirements" \
  "API Requirements" \
  '{
    "auth": "JWT tokens",
    "database": "PostgreSQL",
    "features": ["CRUD users", "Auth system", "Profile management"]
  }'
```

**Step 3: Initialize hive-mind for coordination**
```bash
docker exec claude-flow-alpha claude-flow hive-mind init
```

**Step 4: Monitor in lazydocker**
```bash
# Terminal 1
lazydocker
# Navigate to claude-flow-alpha, press 'l'

# Terminal 2
docker exec claude-flow-alpha claude-flow memory query "API"
```

You'll see agents:
1. **Coordinator** - Organizing search
2. **Researcher** - Finding relevant memories
3. **Optimizer** - Ranking results

## Advanced: Custom Agent Detection

The wrapper automatically detects agents from claude-flow commands with these patterns:
- `hive-mind` - Spawns coordinator agents
- `swarm` - Creates parallel worker agents
- `spawn` - Launches new agent instances
- `agent` - Direct agent operations

### Example with wrapper:
```bash
# This will show agent visualization:
docker exec claude-flow-alpha claude-flow hive-mind spawn \
  "analyze codebase" \
  --mode parallel

# You'll see in logs:
# 🎯 #0 14:30:15 Creating coordinator agent │ Initializing...
# 🔍 #1 14:30:16 Spawning researcher │ Analyzing files...
# 💻 #2 14:30:16 Starting coder │ Processing results...
```

## Troubleshooting

### No Agents Showing Up?

Check if wrapper is working:
```bash
docker exec claude-flow-alpha which claude-flow
# Should show: /usr/local/bin/claude-flow
```

Check logs are being written:
```bash
docker exec claude-flow-alpha ls -la /workspace/logs/agents.log
docker exec claude-flow-alpha tail -20 /workspace/logs/agents.log
```

### Agent Logger Not Loading?

```bash
# Test agent logger manually:
docker exec claude-flow-alpha bash -c '
  source /workspace/lib/agent-logger.sh
  log_agent_start 0 "TestAgent" "coordinator"
  log_agent_action 0 "Testing" "Manual test"
  log_agent_complete 0 "Test done"
  show_active_agents
'
```

## Integration with Your Projects

### Option 1: From Host Machine

```bash
# Map your project into container
export PROJECT_PATH=/path/to/your/project
docker-compose restart

# Now use claude-flow on your code:
docker exec claude-flow-alpha bash -c "cd /workspace/project && claude-flow memory stats"
```

### Option 2: MCP Integration

Copy MCP config to your project:
```bash
cp config/.claude/settings.json ~/your-project/.claude/
cd ~/your-project
claude
```

Then in Claude Code:
```
Claude, using the claude-flow MCP server, store this memory:
"Feature implementation for user auth is complete"
```

You'll see agents in the container logs!

## Performance Tips

1. **Use lazydocker** for best visualization
2. **Keep agent logs** limited with log rotation
3. **Monitor with `make agents`** for status overview
4. **Use `make agents-tail`** for quick checks

## Summary

✅ **Real workflows** - Memory, hive-mind, swarm commands spawn real agents
✅ **8 colored agents** - Each with unique icon and specialization
✅ **Real-time monitoring** - lazydocker, make agents-logs, docker logs
✅ **Structured logging** - ISO timestamps, searchable, parseable
✅ **Production ready** - Non-blocking, zero overhead when inactive

**NOT a demo** - These are actual claude-flow internal agents doing real work!
