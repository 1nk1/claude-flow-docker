# 📦 Installation Guide

Complete installation guide for Claude-Flow Docker.

## 🎯 Quick Installation

### Prerequisites

- **Docker** 20.10 or higher
- **Docker Compose** v2.0 or higher
- **Git** (for cloning)
- **4GB RAM** minimum
- **10GB disk space** for Docker images

Check your versions:
```bash
docker --version
docker compose version
git --version
```

## 🚀 Step-by-Step Installation

### 1. Clone Repository

```bash
git clone https://github.com/1nk1/claude-flow-docker.git
cd claude-flow-docker
```

### 2. Setup

```bash
# Run setup script
make setup

# Or manually:
chmod +x setup.sh
./setup.sh
```

This will:
- Check dependencies
- Create project structure
- Generate `.env` file
- Build Docker image
- Create necessary directories

### 3. Start Container

```bash
make start

# Or:
./cf-start.sh

# Or with Docker Compose:
docker compose up -d
```

### 4. Verify Installation

```bash
# Check container status
make status

# Check versions
./cf-exec.sh node --version        # Should show v22.x.x
./cf-exec.sh claude-flow --version # Should work

# Run tests
make test
```

## 🔧 Configuration

### Environment Variables

Edit `.env` file:

```bash
# Container settings
CONTAINER_NAME=claude-flow-alpha
NODE_ENV=production

# Resource limits
MEMORY_LIMIT=4g
CPU_LIMIT=2.0

# Ports (if needed)
# PORT=3000
```

### MCP Configuration

Copy MCP settings to your project:

```bash
# Copy to your project root
cp config/.claude/settings.json /path/to/your/project/.claude/
```

## 🐳 Docker Installation (if needed)

### Linux

```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker

# Install Docker Compose v2
sudo apt-get update
sudo apt-get install docker-compose-plugin
```

### macOS

```bash
# Install via Homebrew
brew install --cask docker

# Or download from:
# https://www.docker.com/products/docker-desktop
```

### Windows

Download and install Docker Desktop:
https://www.docker.com/products/docker-desktop

Use WSL2 backend for best performance.

## 🎮 Usage

### Basic Commands

```bash
make start              # Start container
make stop               # Stop container
make restart            # Restart
make status             # Check status
make logs               # View logs
make shell              # Interactive shell
```

### Claude-Flow Commands

```bash
# Hive-Mind
make hive-spawn TASK="your task"

# Swarm
make swarm TASK="quick task"

# Memory
make memory-stats
make memory-query Q="search"
```

## 🔗 Claude Code Integration

### 1. Install Claude Code (if not installed)

```bash
npm install -g @anthropic-ai/claude-code
```

### 2. Configure Your Project

```bash
cd your-project
mkdir -p .claude
cp /path/to/claude-flow-docker/config/.claude/settings.json ./.claude/
```

### 3. Start Container

```bash
# Make sure container is running
docker ps | grep claude-flow
```

### 4. Use Claude Code

```bash
# Launch Claude Code
claude

# Claude will automatically use MCP tools from Docker!
```

## 🧪 Testing Installation

```bash
# Run all tests
make test

# Or individual tests
./tests/test-docker-build.sh
./tests/test-mcp-connection.sh
./tests/test-claude-flow.sh
```

## 🐛 Troubleshooting

### Container won't start

```bash
# Clean and rebuild
make clean
make build
make start
```

### Permission errors

```bash
# Make scripts executable
chmod +x *.sh

# Check Docker permissions
docker ps
```

### SQLite errors

```bash
# Initialize fresh
./cf-exec.sh claude-flow init --force
```

### MCP not connecting

```bash
# Check container is running
docker ps | grep claude-flow

# Verify MCP config
cat config/.claude/settings.json

# Test connection
echo '{"jsonrpc":"2.0","id":1,"method":"initialize"}' | \
  docker exec -i claude-flow-alpha npx claude-flow mcp
```

## 📚 Next Steps

1. Read [QUICKSTART.md](QUICKSTART.md) for quick usage
2. Check [README.md](README.md) for full documentation
3. See [INTEGRATION.md](INTEGRATION.md) for advanced integration
4. Review [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for common issues

## 🆘 Get Help

- Check [Troubleshooting Guide](TROUBLESHOOTING.md)
- Open an [Issue](https://github.com/1nk1/claude-flow-docker/issues)
- Read [Documentation](https://github.com/1nk1/claude-flow-docker/wiki)

## 📋 System Requirements

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| CPU | 2 cores | 4+ cores |
| RAM | 4GB | 8GB+ |
| Disk | 10GB | 20GB+ |
| Docker | 20.10+ | Latest |
| OS | Linux, macOS, Windows+WSL2 | Linux |

---

**Installation complete! Ready to use Claude-Flow Docker!** 🎉
