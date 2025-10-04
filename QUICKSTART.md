# ⚡ Quick Start Guide

Get Claude-Flow Docker running in 3 minutes!

## 🎯 Installation

### Prerequisites
- Docker 20.10+
- Docker Compose v2.0+
- 4GB RAM minimum

### 3-Step Installation

```bash
# 1. Clone and enter
git clone https://github.com/1nk1kas/claude-flow-docker.git
cd claude-flow-docker

# 2. Setup
make setup

# 3. Start
make start
```

That's it! ✅

## 🚀 Essential Commands

### With Makefile (Recommended)

```bash
make start              # Start container
make stop               # Stop container
make restart            # Restart
make status             # Check status
make logs               # View logs
make shell              # Open shell
make clean              # Clean up
```

### With Shell Scripts

```bash
./cf-start.sh           # Start
./cf-stop.sh            # Stop
./cf-logs.sh            # Logs
./cf-shell.sh           # Shell
./cf-exec.sh <cmd>      # Execute command
```

## 🐝 Claude-Flow Commands

### Via Makefile

```bash
# Create hive-mind
make hive-spawn TASK="build REST API"

# Quick swarm command
make swarm TASK="create authentication"

# Status and memory
make status
make memory-stats
make memory-query Q="authentication"

# Install packages
make install-package PKG="axios"
```

### Via Docker Exec

```bash
# Hive-Mind
./cf-exec.sh claude-flow hive-mind spawn "build feature" --claude
./cf-exec.sh claude-flow hive-mind status
./cf-exec.sh claude-flow hive-mind resume <session-id>

# Swarm
./cf-exec.sh claude-flow swarm "create API endpoint" --claude

# Memory
./cf-exec.sh claude-flow memory stats
./cf-exec.sh claude-flow memory query "search term"
./cf-exec.sh claude-flow memory list

# GitHub
./cf-exec.sh claude-flow github clone <url>
./cf-exec.sh claude-flow github status
```

## 🔗 Claude Code Integration

### Setup (One Time)

```bash
# In your project root
mkdir -p .claude
cp config/.claude/settings.json ./.claude/settings.json
```

### Usage

```bash
# Make sure container is running
make status

# Launch Claude Code - it auto-connects to Docker!
claude

# Test in Claude Code:
# "Claude, using Claude-Flow from Docker, show hive-mind status"
```

## 📊 Verify Everything Works

```bash
# Check container status
docker ps | grep claude-flow

# Check hive-mind status
make status

# Test commands
make test

# View logs
make logs
```

## 🛠️ Useful Commands

### Backup & Restore

```bash
# Create backup
make backup

# Restore (specify file from ./backups/)
make restore BACKUP=swarm-20250104-120000.tar.gz
```

### Working with Memory

```bash
# Statistics
make memory-stats

# Search
make memory-query Q="API"

# List namespaces
./cf-exec.sh claude-flow memory list
```

### Project Initialization

```bash
# Initialize inside container
make init-project

# Create structure
./cf-exec.sh claude-flow init --force
```

## 🐛 Common Issues

### Container won't start

```bash
make clean
make build
make start
```

### MCP not connecting

```bash
# Check configuration
cat .claude/settings.json

# Check container
docker ps | grep claude-flow

# Test connection
./cf-exec.sh claude-flow --version
```

### SQLite errors

```bash
./cf-exec.sh claude-flow init --force
```

## 📁 File Structure

```
your-project/
├── .claude/
│   └── settings.json        # MCP config (local!)
├── project/                 # Your project files
├── .env                     # Settings (from .env.example)
└── [docker files]           # Dockerfile, compose, scripts
```

## 💡 Workflow Examples

### Pattern 1: Quick Task

```bash
# Run swarm for single task
make swarm TASK="implement user login"

# Or via Claude Code (container must be running)
claude
# Inside Claude Code, MCP tools work automatically
```

### Pattern 2: Complex Project

```bash
# 1. Create hive-mind
make hive-spawn TASK="build microservices architecture"

# 2. Check status
make status

# 3. Continue via Claude Code
cd project
claude
# MCP tools use the hive-mind in container
```

### Pattern 3: Research

```bash
# Start research
make hive-spawn TASK="research GraphQL best practices"

# Search memory
make memory-query Q="GraphQL"

# Statistics
make memory-stats
```

## 🎓 Next Steps

1. Read [INSTALLATION.md](INSTALLATION.md) for detailed setup
2. Configure `.env` for your needs
3. Check [Claude-Flow Wiki](https://github.com/ruvnet/claude-flow/wiki)
4. Try examples above

## 🆘 Help

- `make help` - List all commands
- [GitHub Issues](https://github.com/1nk1kas/claude-flow-docker/issues)
- [Documentation](https://github.com/1nk1kas/claude-flow-docker/wiki)

---

**Happy coding with Claude-Flow! 🐝✨**
