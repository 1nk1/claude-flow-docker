# 🤖 Agent Visualization Guide

Real-time colored visualization for Claude-Flow agents with support for up to 8 concurrent agents.

## Features

- **8 Unique Colors** - Each agent gets a distinct color (Cyan, Pink, Yellow, Green, Purple, Orange, Light Blue, Light Pink)
- **Specialization Icons** - Visual indicators for agent types (🎯 coordinator, 🔍 researcher, 💻 coder, 👀 reviewer, 🧪 tester, ⚡ optimizer, 🎨 designer, 📋 planner)
- **Real-time Status** - Track agent state: ACTIVE, COMPLETED, ERROR
- **Action Logging** - See what each agent is doing in real-time
- **JSON State** - Agent state persisted in `/workspace/.swarm/agents/`

## Quick Start

### Run Demo

```bash
./demo-agents.sh
```

This will simulate 8 agents working on a project with colored output.

### View Active Agents

```bash
make agents
```

Shows all active agents with their current status, specialization, and last action.

### Watch Agent Logs

```bash
make agents-logs        # Live tail of agent activity
make agents-tail        # Last 50 lines of agent logs
```

### In lazydocker

Open lazydocker and run:

```bash
docker logs -f claude-flow-alpha
```

You'll see colorful real-time agent activity as they work!

## Agent Colors

| ID | Color | Emoji | Specialization |
|----|-------|-------|----------------|
| 0  | Cyan  | 🎯 | Coordinator |
| 1  | Pink  | 🔍 | Researcher |
| 2  | Yellow | 💻 | Coder |
| 3  | Green | 👀 | Reviewer |
| 4  | Purple | 🧪 | Tester |
| 5  | Orange | ⚡ | Optimizer |
| 6  | Light Blue | 🎨 | Designer |
| 7  | Light Pink | 📋 | Planner |

## Log Formats

### Console Output (Colored)
```
🎯 Agent #0 CoordinatorAgent [coordinator]
   ├─ Started at 13:49:45
   └─ Status: ACTIVE

🎯 #0 13:49:50 Analyzing project requirements │ Initial analysis phase
```

### File Log (/workspace/logs/agents.log)
```
[2025-11-17T13:49:45Z] AGENT_START | ID=0 | NAME=CoordinatorAgent | SPEC=coordinator
[2025-11-17T13:49:50Z] AGENT_ACTION | ID=0 | ACTION=Analyzing project requirements | DETAILS=Initial analysis phase
[2025-11-17T13:49:58Z] AGENT_COMPLETE | ID=0 | RESULT=Coordination completed
```

## How It Works

### Agent Logger (`lib/agent-logger.sh`)

Main library for agent visualization:

- `log_agent_start <id> <name> <specialization>` - Register new agent
- `log_agent_action <id> <action> [details]` - Log agent action
- `log_agent_complete <id> [result]` - Mark agent as completed
- `log_agent_error <id> <error>` - Log agent error
- `show_active_agents` - Display status of all active agents

### Claude-Flow Wrapper (`lib/claude-flow-wrapper.sh`)

Intercepts `claude-flow` commands and automatically logs agent activity:

```bash
claude-flow swarm create "build API"
# Automatically logs agent creation and actions with colors
```

### Agent State

Each agent's state is stored in JSON:

```json
{
  "id": 0,
  "name": "CoordinatorAgent",
  "specialization": "coordinator",
  "status": "active",
  "started_at": "2025-11-17T13:49:45Z",
  "last_action": "Analyzing project requirements"
}
```

## Integration with Claude-Flow

The wrapper automatically detects and logs agents from:

- `claude-flow hive-mind spawn`
- `claude-flow swarm create`
- `claude-flow agent list`

## Viewing in lazydocker

1. Open lazydocker:
   ```bash
   lazydocker
   ```

2. Navigate to `claude-flow-alpha` container

3. Press `l` to view logs

4. Run any claude-flow command that spawns agents

5. Watch colorful real-time agent activity!

## Log Files

- **Agent logs**: `/workspace/logs/agents.log` - Structured agent activity
- **Main logs**: `/workspace/logs/claude-flow.log` - General claude-flow output
- **Agent state**: `/workspace/.swarm/agents/agent_*.json` - Agent state files

## Examples

### Simple Example

```bash
docker exec claude-flow-alpha bash -c '
source /workspace/lib/agent-logger.sh

log_agent_start 0 "MyAgent" "coder"
log_agent_action 0 "Writing code" "Implementing feature X"
log_agent_complete 0 "Success"
'
```

### Multiple Agents

```bash
docker exec claude-flow-alpha bash -c '
source /workspace/lib/agent-logger.sh

log_agent_start 0 "Coordinator" "coordinator"
log_agent_start 1 "Researcher" "researcher"
log_agent_start 2 "Coder" "coder"

log_agent_action 0 "Coordinating work"
log_agent_action 1 "Gathering docs"
log_agent_action 2 "Writing code"

show_active_agents
'
```

## Customization

### Add New Specialization

Edit `lib/agent-logger.sh`:

```bash
declare -A AGENT_ICONS=(
    ["coordinator"]="🎯"
    ["mytype"]="🚀"      # Add your icon
    # ...
)
```

### Change Colors

Edit the `AGENT_COLORS` array in `lib/agent-logger.sh`:

```bash
declare -A AGENT_COLORS=(
    [0]="\033[38;5;51m"   # Change color code
    # ...
)
```

Color codes use 256-color palette. See: https://en.wikipedia.org/wiki/ANSI_escape_code#8-bit

## Troubleshooting

### Colors not showing

Make sure your terminal supports 256 colors:
```bash
echo $TERM  # Should be xterm-256color or similar
```

### Logs not appearing

Check log file permissions:
```bash
docker exec claude-flow-alpha ls -la /workspace/logs/
```

### Agent state not persisting

Verify agent state directory:
```bash
docker exec claude-flow-alpha ls -la /workspace/.swarm/agents/
```

## Performance

- **Minimal overhead** - Logging is async and non-blocking
- **Efficient storage** - Only last 8 active agents kept in memory
- **Log rotation** - Logs automatically managed by container

## Advanced Usage

### Filter Agents by Status

```bash
docker exec claude-flow-alpha bash -c '
source /workspace/lib/agent-logger.sh
for f in /workspace/.swarm/agents/agent_*.json; do
  status=$(jq -r .status "$f")
  [ "$status" = "active" ] && jq . "$f"
done
'
```

### Agent Activity Report

```bash
docker exec claude-flow-alpha bash -c '
grep AGENT_ACTION /workspace/logs/agents.log | \
  awk -F"|" "{print \$3}" | \
  sort | uniq -c | sort -rn
'
```

## Support

For issues or questions about agent visualization:
- Check logs: `make agents-tail`
- View state: `docker exec claude-flow-alpha ls /workspace/.swarm/agents/`
- Run demo: `./demo-agents.sh`
