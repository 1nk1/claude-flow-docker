# 🔌 MCP Connection Guide

Complete guide for connecting Claude Code to claude-flow running in Docker.

## 📋 Table of Contents

- [Overview](#overview)
- [Quick Start](#quick-start)
- [Manual Setup](#manual-setup)
- [Verification](#verification)
- [Troubleshooting](#troubleshooting)
- [Advanced Configuration](#advanced-configuration)

## Overview

This guide shows you how to connect your local Claude Code installation to the claude-flow MCP server running inside Docker. The connection uses **stdio** protocol via `docker exec`.

### How It Works

```
┌─────────────────┐
│  Claude Code    │
│  (Local)        │
└────────┬────────┘
         │ stdio over docker exec
         ▼
┌─────────────────────────┐
│  Docker Container       │
│  claude-flow-alpha      │
│                         │
│  ┌──────────────────┐   │
│  │ MCP Server       │   │
│  │ claude-flow@alpha│   │
│  └──────────────────┘   │
│                         │
│  ┌──────────────────┐   │
│  │ Swarm + Agents   │   │
│  └──────────────────┘   │
└─────────────────────────┘
```

## Quick Start

### Prerequisites

1. **Docker container running:**
   ```bash
   cd /path/to/claude-flow-docker
   make start
   # or
   docker-compose up -d
   ```

2. **Verify container:**
   ```bash
   docker ps | grep claude-flow-alpha
   ```

### Automatic Setup (Recommended)

Use the connection script:

```bash
cd /path/to/claude-flow-docker
./connect-mcp.sh ~/projects/your-project
```

This script will:
- ✅ Check if Docker container is running
- ✅ Create `.claude` directory in your project
- ✅ Generate MCP configuration
- ✅ Test the connection
- ✅ Backup existing settings (if any)

### Test Connection

1. Navigate to your project:
   ```bash
   cd ~/projects/your-project
   ```

2. Start Claude Code:
   ```bash
   claude
   ```

3. Ask Claude to use MCP tools:
   ```
   Show me the claude-flow swarm status using MCP
   ```

   Or:
   ```
   Create a swarm and spawn an agent using claude-flow MCP tools
   ```

## Manual Setup

If you prefer manual configuration:

### Step 1: Create Configuration

```bash
cd your-project
mkdir -p .claude
```

### Step 2: Create settings.json

```bash
cat > .claude/settings.json << 'EOF'
{
  "mcpServers": {
    "claude-flow": {
      "command": "docker",
      "args": [
        "exec",
        "-i",
        "claude-flow-alpha",
        "npx",
        "claude-flow@alpha",
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
```

### Step 3: Verify

```bash
# Check configuration
cat .claude/settings.json | jq .

# Test Docker connection
docker exec -i claude-flow-alpha npx claude-flow@alpha --version
```

## Verification

### 1. Check Container Status

```bash
docker ps | grep claude-flow-alpha
```

Expected output:
```
CONTAINER ID   IMAGE            STATUS    PORTS                    NAMES
abc123def456   claude-flow...   Up...     0.0.0.0:8811->8811/tcp   claude-flow-alpha
```

### 2. Test MCP Server

```bash
# Simple version check
docker exec -i claude-flow-alpha npx claude-flow@alpha --version

# Test MCP protocol (JSON-RPC)
echo '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{}}' | \
  docker exec -i claude-flow-alpha npx claude-flow@alpha mcp start | head -20
```

### 3. List MCP Servers in Claude Code

From your project directory:

```bash
claude mcp list
```

Expected output:
```
Checking MCP server health...

claude-flow: docker exec -i claude-flow-alpha npx claude-flow@alpha mcp start - ✓ Connected
```

### 4. Test in Claude Code

Start Claude Code and ask:

```
List all available MCP tools from claude-flow
```

You should see **87 MCP tools** available:
- swarm_init
- agent_spawn
- task_orchestrate
- memory_usage
- neural_train
- And many more...

## Troubleshooting

### Issue: Container not running

**Error:** `Container 'claude-flow-alpha' is not running`

**Solution:**
```bash
cd /path/to/claude-flow-docker
docker-compose up -d
# or
make start
```

### Issue: MCP connection failed

**Error:** `MCP server "claude-flow" failed to connect`

**Diagnosis:**
```bash
# 1. Check container health
docker ps | grep claude-flow

# 2. Check container logs
docker logs claude-flow-alpha --tail 50

# 3. Test manually
docker exec -i claude-flow-alpha npx claude-flow@alpha mcp --help
```

**Solutions:**

1. **Restart container:**
   ```bash
   docker restart claude-flow-alpha
   ```

2. **Rebuild container:**
   ```bash
   docker-compose down
   docker-compose up -d --build
   ```

3. **Check permissions:**
   ```bash
   ls -la .claude/settings.json
   # Should be readable
   ```

### Issue: better-sqlite3 error

**Error:** `Error loading better-sqlite3`

**Solution:**
```bash
cd /path/to/claude-flow-docker
./fix-node22.sh
make clean && make build && make start
```

### Issue: Wrong project mounted

**Error:** Files not accessible in Docker

**Solution:**

1. Check `.env` file:
   ```bash
   cat .env | grep PROJECT_PATH
   ```

2. Update project path:
   ```bash
   # Edit .env
   PROJECT_PATH=/path/to/your/actual/project

   # Restart
   docker-compose down
   docker-compose up -d
   ```

### Issue: MCP tools not appearing

**Symptom:** Claude Code doesn't show MCP tools

**Diagnosis:**
```bash
# Check if tools are available
echo '{"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}}' | \
  docker exec -i claude-flow-alpha npx claude-flow@alpha mcp start | jq '.result.tools[] | .name' | head -20
```

**Solution:**

1. **Restart Claude Code**
2. **Clear Claude Code cache:**
   ```bash
   rm -rf ~/.claude/cache
   ```

3. **Verify settings.json:**
   ```bash
   cat .claude/settings.json | jq '.mcpServers["claude-flow"]'
   ```

## Advanced Configuration

### Multiple Projects

Connect multiple projects to the same Docker container:

```bash
# Project 1
./connect-mcp.sh ~/projects/project1

# Project 2
./connect-mcp.sh ~/projects/project2

# Project 3
./connect-mcp.sh ~/Desktop/test-app
```

Each project will have its own `.claude/settings.json` pointing to the same container.

### Custom Container Name

If you changed the container name:

```json
{
  "mcpServers": {
    "claude-flow": {
      "command": "docker",
      "args": [
        "exec",
        "-i",
        "your-custom-container-name",  // Changed this
        "npx",
        "claude-flow@alpha",
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
```

### Add Hooks (Optional)

Enhance with automation hooks:

```json
{
  "mcpServers": {
    "claude-flow": {
      "command": "docker",
      "args": ["exec", "-i", "claude-flow-alpha", "npx", "claude-flow@alpha", "mcp", "start"],
      "env": {
        "CLAUDE_FLOW_HOME": "/workspace",
        "CLAUDE_FLOW_PROJECT": "/workspace/project",
        "CLAUDE_FLOW_STORAGE": "/workspace/.swarm"
      }
    }
  },
  "hooks": {
    "postEdit": {
      "command": "docker",
      "args": ["exec", "claude-flow-alpha", "npx", "claude-flow@alpha", "hooks", "post-edit", "--file", "{file}"]
    },
    "preTask": {
      "command": "docker",
      "args": ["exec", "claude-flow-alpha", "npx", "claude-flow@alpha", "hooks", "pre-task", "--description", "{description}"]
    }
  }
}
```

### Debug Mode

Enable verbose logging:

```json
{
  "mcpServers": {
    "claude-flow": {
      "command": "docker",
      "args": ["exec", "-i", "claude-flow-alpha", "npx", "claude-flow@alpha", "mcp", "start"],
      "env": {
        "CLAUDE_FLOW_HOME": "/workspace",
        "CLAUDE_FLOW_PROJECT": "/workspace/project",
        "CLAUDE_FLOW_STORAGE": "/workspace/.swarm",
        "MCP_DEBUG": "true",
        "CLAUDE_FLOW_LOG_LEVEL": "debug"
      }
    }
  }
}
```

Then check logs:
```bash
docker logs claude-flow-alpha -f
```

## Testing MCP Tools

### Test Swarm Creation

In Claude Code:

```
Using claude-flow MCP, create a swarm with mesh topology and spawn a coder agent
```

### Test Memory Operations

```
Using MCP, store a value in memory with key "test-key" and value "hello world"
```

### Test Neural Training

```
Use MCP to check neural network status
```

### List All Tools

```
Show me all available MCP tools from claude-flow and explain what they do
```

## Common MCP Commands

### From Claude Code (Natural Language)

- "Create a swarm and spawn 3 agents"
- "Show swarm status"
- "List all active agents"
- "Store data in memory"
- "Check neural network status"
- "Generate performance report"

### From Terminal (Direct)

```bash
# Via Docker
docker exec -i claude-flow-alpha npx claude-flow@alpha swarm init --topology mesh

# Via MCP JSON-RPC
echo '{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"swarm_init","arguments":{"topology":"mesh"}}}' | \
  docker exec -i claude-flow-alpha npx claude-flow@alpha mcp start
```

## Performance Tips

1. **Keep container running:** Don't stop/start frequently
2. **Use persistent volumes:** Data persists across restarts
3. **Monitor resources:**
   ```bash
   docker stats claude-flow-alpha --no-stream
   ```

4. **Backup regularly:**
   ```bash
   make backup
   ```

## Security Considerations

1. **Docker socket access:** The configuration uses `docker exec`, which requires Docker access
2. **Container isolation:** claude-flow runs isolated in Docker
3. **No exposed ports:** MCP uses stdio, not network ports
4. **Environment variables:** Secrets should be in `.env`, not settings.json

## Reference

### Configuration Schema

```typescript
{
  mcpServers: {
    "claude-flow": {
      command: "docker",                    // Docker CLI
      args: string[],                       // Docker exec arguments
      env: {                                // Environment variables
        CLAUDE_FLOW_HOME: string,           // Home directory in container
        CLAUDE_FLOW_PROJECT: string,        // Project path in container
        CLAUDE_FLOW_STORAGE: string         // Storage path in container
      }
    }
  }
}
```

### Available MCP Tools (87 total)

**Swarm & Coordination:**
- swarm_init, swarm_status, swarm_monitor, swarm_scale, swarm_destroy
- agent_spawn, agent_list, agent_metrics
- task_orchestrate, task_status, task_results

**Memory & Storage:**
- memory_usage, memory_search, memory_persist, memory_backup, memory_restore

**Neural Networks:**
- neural_status, neural_train, neural_predict, neural_patterns
- model_load, model_save

**Performance:**
- performance_report, bottleneck_analyze, token_usage
- benchmark_run, metrics_collect

**GitHub Integration:**
- github_repo_analyze, github_pr_manage, github_issue_track

**And 50+ more specialized tools...**

## Support

- 📖 [Main Documentation](../README.md)
- 🐛 [Report Issues](https://github.com/1nk1/claude-flow-docker/issues)
- 💬 [Discussions](https://github.com/1nk1/claude-flow-docker/discussions)
- 🔧 [Troubleshooting](../TROUBLESHOOTING.md)

---

**Built with ❤️ for seamless MCP integration**
