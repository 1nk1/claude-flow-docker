# 🔌 Claude-Flow MCP Docker Setup

Complete guide to connect Claude Code to claude-flow MCP server running in Docker.

## 🎯 Quick Start (3 Steps)

### 1. Start Container

```bash
cd /path/to/claude-flow-docker
make start
# or: docker-compose up -d
```

### 2. Connect Your Project

```bash
./connect-mcp.sh ~/projects/your-project
```

### 3. Use Claude Code

```bash
cd ~/projects/your-project
claude
```

Ask Claude:
```
Show me the claude-flow swarm status
```

## ✅ Verify Connection

```bash
# Check MCP status
claude mcp list

# Should show:
# claude-flow: docker exec -i claude-flow-alpha claude-flow mcp start - ✓ Connected
```

## 📁 Project Files

### Created Files

- **`/connect-mcp.sh`** - Automatic connection setup script
- **`/docs/MCP_CONNECTION.md`** - Complete connection guide
- **`/docs/QUICKSTART_MCP.md`** - 3-minute quick start
- **`/docs/MCP_SETUP_SUMMARY.md`** - Architecture & configuration reference
- **`/config/.claude/settings.json`** - MCP configuration template

### Modified Files

- **`docker-entrypoint.sh`** - Updated to support stdio MCP (not TCP)
- **`.env.example`** - MCP configuration examples

## 🔧 How It Works

```
Local Machine                           Docker Container
┌─────────────────────┐                 ┌──────────────────────────┐
│  Claude Code        │   docker exec   │  claude-flow-alpha       │
│                     ├────────────────→│                          │
│  .mcp.json:         │      stdio      │  claude-flow mcp start   │
│  docker exec -i ... │←────────────────┤  (87 MCP tools)          │
└─────────────────────┘                 └──────────────────────────┘
```

**Key Points:**
- MCP uses **stdio protocol**, not HTTP/TCP
- Connection via `docker exec -i` for interactive stdin/stdout
- claude-flow installed globally in container at `/usr/local/bin/claude-flow`

## 📋 Configuration

### MCP Configuration (`.mcp.json` or `.claude/settings.json`)

```json
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
```

### Manual Setup

If you prefer manual configuration:

```bash
# 1. Start container
docker-compose up -d

# 2. Create .claude directory in your project
cd ~/projects/your-project
mkdir -p .claude

# 3. Copy configuration template
cp /path/to/claude-flow-docker/config/.claude/settings.json ./.claude/

# 4. Verify
claude mcp list
```

## 🚀 Usage Examples

### In Claude Code (Natural Language)

```
Create a mesh swarm with 5 agents: researcher, coder, tester, reviewer, architect
```

```
Show swarm status and list all active agents
```

```
Store in memory: api_endpoint = "https://api.example.com"
```

```
Generate a performance report for the last 24 hours
```

### Direct Commands (Terminal)

```bash
# Create swarm
docker exec -i claude-flow-alpha claude-flow swarm init --topology mesh

# List agents
docker exec -i claude-flow-alpha claude-flow agent list

# Memory operations
docker exec -i claude-flow-alpha claude-flow memory stats

# Performance report
docker exec -i claude-flow-alpha claude-flow performance report
```

### JSON-RPC (Advanced)

```bash
# Test MCP protocol directly
echo '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{}}' | \
  docker exec -i claude-flow-alpha claude-flow mcp start
```

## 🔍 Available MCP Tools (87 Total)

### Categories

**Swarm & Coordination:**
- swarm_init, swarm_status, swarm_monitor, swarm_scale, swarm_destroy
- agent_spawn, agent_list, agent_metrics, coordination_sync

**Memory & Storage:**
- memory_usage, memory_search, memory_persist, memory_backup
- memory_restore, memory_compress, memory_sync

**Neural Networks:**
- neural_status, neural_train, neural_predict, neural_patterns
- model_load, model_save, inference_run

**Performance:**
- performance_report, bottleneck_analyze, token_usage
- benchmark_run, metrics_collect, health_check

**GitHub Integration:**
- github_repo_analyze, github_pr_manage, github_issue_track
- github_code_review, github_metrics

**Workflows:**
- workflow_create, workflow_execute, automation_setup
- pipeline_create, batch_process, parallel_execute

**And 50+ more specialized tools...**

## 🐛 Troubleshooting

### Container Not Running

```bash
# Start container
docker-compose up -d

# Check status
docker ps | grep claude-flow
```

### MCP Connection Failed

```bash
# Check container logs
docker logs claude-flow-alpha --tail 50

# Restart container
docker restart claude-flow-alpha

# Verify MCP command works
docker exec -i claude-flow-alpha claude-flow --version
```

### Wrong Path Error

If you see: `Failed to connect: /home/appuser/node_modules/.bin/claude-flow`

**Fix:** Update configuration to use global command:

```json
{
  "mcpServers": {
    "claude-flow": {
      "command": "docker",
      "args": ["exec", "-i", "claude-flow-alpha", "claude-flow", "mcp", "start"]
    }
  }
}
```

### better-sqlite3 Error

```bash
./fix-node22.sh
make clean && make build && make start
```

## 📚 Documentation

| Document | Description |
|----------|-------------|
| [MCP_CONNECTION.md](docs/MCP_CONNECTION.md) | Complete connection guide with troubleshooting |
| [QUICKSTART_MCP.md](docs/QUICKSTART_MCP.md) | 3-minute quick start guide |
| [MCP_SETUP_SUMMARY.md](docs/MCP_SETUP_SUMMARY.md) | Architecture & technical details |
| [README.md](README.md) | Main project README |
| [TROUBLESHOOTING.md](TROUBLESHOOTING.md) | General troubleshooting guide |

## 🎯 Multiple Projects

Connect multiple projects to the same Docker container:

```bash
# Project 1
./connect-mcp.sh ~/projects/project1

# Project 2
./connect-mcp.sh ~/projects/project2

# Project 3
./connect-mcp.sh ~/Desktop/test-app
```

Each project gets its own `.claude/settings.json` pointing to the container.

## 🔄 Updating

### Update Docker Container

```bash
docker-compose down
docker-compose pull
docker-compose up -d --build
```

### Update MCP Configuration

```bash
# Re-run connection script
./connect-mcp.sh ~/projects/your-project
```

## 📊 Container Stats

Monitor Docker resource usage:

```bash
# Single check
docker stats claude-flow-alpha --no-stream

# Continuous monitoring
docker stats claude-flow-alpha
```

## 🛠️ Development

### Modify MCP Configuration

Edit template:
```bash
vim config/.claude/settings.json
```

Then reconnect projects:
```bash
./connect-mcp.sh ~/projects/your-project
```

### Add Custom Tools

1. Update claude-flow in container
2. Restart container
3. Test new tools in Claude Code

## 💡 Tips & Best Practices

1. **Keep container running** - Don't stop/start frequently
2. **Backup regularly** - Use `make backup`
3. **Monitor resources** - Check `docker stats` periodically
4. **Use persistent volumes** - Data persists across restarts
5. **Version control configs** - Commit `.mcp.json` to git

## 🎉 Success Indicators

When everything works correctly:

✅ `claude mcp list` shows "✓ Connected"
✅ Docker container is running (`docker ps`)
✅ Claude Code starts without errors
✅ MCP tools available in Claude Code
✅ Can create swarms and spawn agents
✅ Memory and neural features working

## 📞 Support

- 🐛 [Report Issues](https://github.com/1nk1/claude-flow-docker/issues)
- 💬 [Discussions](https://github.com/1nk1/claude-flow-docker/discussions)
- 📖 [Wiki](https://github.com/1nk1/claude-flow-docker/wiki)
- 🔧 [Claude-Flow Docs](https://github.com/ruvnet/claude-flow)

## 🏆 Achievements

- ✅ MCP server running in Docker
- ✅ Local Claude Code connection via stdio
- ✅ 87 MCP tools available
- ✅ Automatic connection script
- ✅ Complete documentation
- ✅ Production ready

---

**Status:** ✅ Production Ready
**Version:** 1.0.0
**Docker:** claude-flow-alpha
**MCP Protocol:** stdio over docker exec
**Claude-Flow:** v2.7.0-alpha.10

**Happy coding with claude-flow! 🚀**
