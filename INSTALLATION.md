# Installation Guide

Complete installation guide for Claude-Flow Docker.

## System Requirements

### Minimum Requirements

- **OS**: Linux, macOS, or Windows with WSL2
- **Docker**: 20.10 or higher
- **Docker Compose**: v2.0 or higher
- **RAM**: 4GB minimum
- **Disk**: 10GB free space
- **CPU**: 2 cores recommended

### Recommended Requirements

- **RAM**: 8GB or more
- **CPU**: 4 cores or more (M1/M2/M4 recommended)
- **Disk**: 20GB+ free space (for large projects)

## Pre-Installation

### 1. Install Docker

**macOS:**
```bash
brew install --cask docker
```

**Linux:**
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
```

**Windows:**
Download Docker Desktop from https://www.docker.com/products/docker-desktop

### 2. Install Docker Compose

Docker Desktop includes Compose. For Linux:
```bash
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

### 3. Verify Installation

```bash
docker --version
docker-compose --version
```

## Installation Steps

### Step 1: Clone Repository

```bash
git clone https://github.com/1nk1/claude-flow-docker.git
cd claude-flow-docker
```

### Step 2: Configure Environment

```bash
cp .env.example .env
```

Edit `.env` and set:

```bash
# Required
ANTHROPIC_API_KEY=your-api-key-here

# Optional - adjust for your system
CONTAINER_CPU_LIMIT=2           # Number of CPU cores
CONTAINER_MEMORY_LIMIT=4G       # RAM allocation
```

### Step 3: Setup

```bash
chmod +x *.sh
make setup
```

This will:
- Validate Docker installation
- Create required directories
- Set up volumes
- Configure permissions

### Step 4: Build Container

```bash
make build
```

This takes 3-5 minutes and installs:
- Node.js 22
- Claude Code CLI
- Claude-Flow @alpha
- Agent visualization tools

### Step 5: Start Container

```bash
make start
```

Wait 30 seconds for initialization.

### Step 6: Verify

```bash
make status
```

Expected output:
```
Container: claude-flow-alpha
Status: running
Claude-Flow: v2.7.35
MCP Server: Ready
```

## Post-Installation

### Test Claude-Flow

```bash
docker exec -it claude-flow-alpha claude-flow --version
docker exec -it claude-flow-alpha claude-flow memory stats
```

### Run Agent Demo

```bash
./demo-agents.sh
```

### View Logs

```bash
make logs
make agents
```

## MCP Integration

### Option 1: Per-Project Configuration

```bash
cd ~/your-project
mkdir -p .claude
cp /path/to/claude-flow-docker/config/.claude/settings.json ./.claude/
```

### Option 2: Global Configuration

```bash
mkdir -p ~/.config/claude
cp /path/to/claude-flow-docker/config/.claude/settings.json ~/.config/claude/
```

### Test MCP Connection

```bash
cd ~/your-project
claude
```

In Claude Code:
```
Claude, show me available MCP tools
```

## Configuration Options

### Environment Variables

Edit `.env` to customize:

```bash
# Debug logging
CLAUDE_FLOW_DEBUG=true
CLAUDE_FLOW_VERBOSE=true
CLAUDE_FLOW_LOG_LEVEL=debug

# MCP settings
MCP_DEBUG=true
MCP_LOG_LEVEL=debug

# Resource limits (adjust for your system)
CONTAINER_CPU_LIMIT=2
CONTAINER_MEMORY_LIMIT=4G
CONTAINER_CPU_RESERVATION=1
CONTAINER_MEMORY_RESERVATION=2G
```

### Project Path

To work with a specific project:

```bash
# In .env
PROJECT_PATH=/path/to/your/project
```

Or use the switcher:

```bash
./switch-project.sh /path/to/your/project
```

## Updating

### Update Claude-Flow

Container uses `@latest` and `@alpha` tags for automatic updates:

```bash
make clean
make build
make start
```

### Update Container

```bash
git pull origin main
make rebuild
```

## Uninstallation

### Stop and Remove Container

```bash
make clean
```

### Remove Volumes (CAUTION: Deletes all data)

```bash
make clean-volumes
```

### Remove Repository

```bash
cd ..
rm -rf claude-flow-docker
```

## Verification Checklist

After installation, verify:

- [ ] Container running: `docker ps | grep claude-flow`
- [ ] Claude-Flow installed: `docker exec claude-flow-alpha claude-flow --version`
- [ ] MCP config exists: `ls config/.claude/settings.json`
- [ ] Logs working: `make logs`
- [ ] Agent demo works: `./demo-agents.sh`
- [ ] Memory system initialized: `docker exec claude-flow-alpha claude-flow memory stats`

## Platform-Specific Notes

### macOS (M1/M2/M4)

```bash
# Recommended settings in .env
CONTAINER_CPU_LIMIT=4
CONTAINER_MEMORY_LIMIT=8G
```

### Linux

```bash
# May need to add user to docker group
sudo usermod -aG docker $USER
newgrp docker
```

### Windows (WSL2)

```bash
# Use WSL2 backend in Docker Desktop
# Clone repo in WSL filesystem for better performance
cd ~
git clone https://github.com/1nk1/claude-flow-docker.git
```

## Troubleshooting Installation

### Build fails

```bash
make clean
docker system prune -a
make build
```

### Permission denied

```bash
chmod +x *.sh scripts/*.sh
sudo chown -R $USER:$USER .
```

### Out of memory

Increase limits in `.env`:
```bash
CONTAINER_MEMORY_LIMIT=8G
```

### Port conflicts

Change port in `docker-compose.yml`:
```yaml
ports:
  - "8812:8811"  # Use 8812 instead of 8811
```

## Next Steps

1. Read [QUICKSTART.md](QUICKSTART.md) for quick usage
2. See [AGENT_VISUALIZATION.md](AGENT_VISUALIZATION.md) for agent features
3. Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for issues
4. View [README.md](README.md) for complete docs

## Support

- Issues: https://github.com/1nk1/claude-flow-docker/issues
- Docs: [README.md](README.md)
- Demo: `./demo-agents.sh`
