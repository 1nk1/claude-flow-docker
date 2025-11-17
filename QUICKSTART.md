# Quick Start Guide

Get Claude-Flow Docker running in 3 minutes.

## Prerequisites

- Docker 20.10+
- Docker Compose v2.0+
- 4GB RAM minimum

## Installation

### 1. Clone Repository

```bash
git clone https://github.com/1nk1/claude-flow-docker.git
cd claude-flow-docker
```

### 2. Setup Environment

```bash
make setup
```

This will:
- Create `.env` from `.env.example`
- Setup volumes and permissions
- Validate configuration

### 3. Start Container

```bash
make start
```

Wait 30 seconds for initialization.

### 4. Verify Installation

```bash
make status
```

Expected output:
```
✅ Container running
✅ Claude-Flow installed
✅ MCP server ready
```

## First Steps

### Test Claude-Flow

```bash
docker exec -it claude-flow-alpha claude-flow --version
```

Should show: `v2.7.35` or higher

### View Agent Visualization

```bash
./demo-agents.sh
```

You'll see 8 colored agents working in real-time!

### Check Memory

```bash
docker exec -it claude-flow-alpha claude-flow memory stats
```

## Using with Claude Code

### 1. Copy MCP Config

```bash
cp config/.claude/settings.json ~/your-project/.claude/
```

### 2. Start Claude Code

```bash
cd ~/your-project
claude
```

### 3. Test Connection

In Claude Code:
```
Claude, using Claude-Flow from Docker, show me the hive-mind status
```

## Quick Commands

```bash
make start              # Start container
make stop               # Stop container
make status             # Check status
make logs               # View logs
make shell              # Interactive shell
make agents             # View active agents
make agents-logs        # Follow agent logs
```

## Troubleshooting

### Container won't start

```bash
make clean
make build
make start
```

### MCP not connecting

```bash
make restart
docker logs claude-flow-alpha
```

### Permission errors

```bash
chmod +x *.sh
```

## Next Steps

- Read [INSTALLATION.md](INSTALLATION.md) for detailed setup
- See [AGENT_VISUALIZATION.md](AGENT_VISUALIZATION.md) for agent features
- Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for common issues
- View [README.md](README.md) for complete documentation

## Examples

### Create a Swarm

```bash
docker exec -it claude-flow-alpha claude-flow swarm create "build REST API" --claude
```

### Spawn Hive-Mind

```bash
docker exec -it claude-flow-alpha claude-flow hive-mind spawn "implement feature" --claude
```

### Query Memory

```bash
docker exec -it claude-flow-alpha claude-flow memory query "search term"
```

## Getting Help

- Documentation: [README.md](README.md)
- Issues: https://github.com/1nk1/claude-flow-docker/issues
- Demo: `./demo-agents.sh`

## What's Next?

1. **Try the demo**: `./demo-agents.sh`
2. **Explore agents**: `make agents`
3. **Watch logs**: `make agents-logs`
4. **Connect Claude Code**: Follow [MCP Setup](docs/mcp/README.md)

Happy coding with Claude-Flow! 🚀
