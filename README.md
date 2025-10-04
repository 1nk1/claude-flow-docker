# 🐳 Claude-Flow Docker

[![Stars](https://img.shields.io/github/stars/1nk1/claude-flow-docker?style=for-the-badge&logo=github&color=yellow)](https://github.com/1nk1/claude-flow-docker)
[![Downloads](https://img.shields.io/github/downloads/1nk1/claude-flow-docker/total?style=for-the-badge&logo=github&color=blue)](https://github.com/1nk1/claude-flow-docker/releases/tag/v1.0.0)
[![Version](https://img.shields.io/badge/v1.0.0-blue?style=for-the-badge&label=VERSION)](https://github.com/1nk1/claude-flow-docker/releases/tag/v1.0.0)
[![Node.js](https://img.shields.io/badge/node-22.x-green?style=for-the-badge&logo=node.js)](https://nodejs.org/)
[![Docker](https://img.shields.io/badge/docker-20.10+-blue?style=for-the-badge&logo=docker)](https://www.docker.com/)
[![Claude Code](https://img.shields.io/badge/CLAUDE_CODE-INTEGRATED-green?style=for-the-badge)](https://docs.anthropic.com/)

[![Agentics Foundation](https://img.shields.io/badge/AGENTICS-FOUNDATION-red?style=for-the-badge)](#)
[![Hive-Mind](https://img.shields.io/badge/🐝_HIVE--MIND-AI_COORDINATION-purple?style=for-the-badge)](#)
[![Neural](https://img.shields.io/badge/NEURAL-27_MODELS-orange?style=for-the-badge)](#)
[![MCP Tools](https://img.shields.io/badge/MCP_TOOLS-87-blue?style=for-the-badge)](#)

[![License](https://img.shields.io/badge/LICENSE-MIT-yellow?style=for-the-badge)](LICENSE)

---

**CI/CD Status:**

[![Docker Build](https://github.com/1nk1/claude-flow-docker/actions/workflows/docker-build.yml/badge.svg)](https://github.com/1nk1/claude-flow-docker/actions/workflows/docker-build.yml)
[![MCP Tests](https://github.com/1nk1/claude-flow-docker/actions/workflows/mcp-integration.yml/badge.svg)](https://github.com/1nk1/claude-flow-docker/actions/workflows/mcp-integration.yml)
[![Docs](https://github.com/1nk1/claude-flow-docker/actions/workflows/docs.yml/badge.svg)](https://github.com/1nk1/claude-flow-docker/actions/workflows/docs.yml)

---

> 🚀 Isolated Docker environment for [Claude-Flow](https://github.com/ruvnet/claude-flow) with local Claude Code integration

Full-featured AI orchestration in a Docker container with automatic MCP server setup, persistent storage, and hooks system.

## ✨ Features

- 🐝 **Hive-Mind Intelligence** - AI agent coordination in isolated environment
- 🧠 **27+ Neural Models** - WASM SIMD acceleration
- 🔧 **87 MCP Tools** - Complete toolkit for AI orchestration
- 💾 **SQLite Persistent Storage** - Data persists between runs
- 🪝 **Hooks System** - Workflow automation (pre/post edit, sessions)
- 🔗 **Local MCP Integration** - Connect to Claude Code without global install
- 📦 **Node.js 22** - Latest LTS version
- 🛡️ **Isolated Environment** - Doesn't affect your system

## 🎯 Quick Start

### Requirements

- Docker 20.10+
- Docker Compose v2.0+
- Claude Code (for integration)
- 4GB RAM minimum

### Installation in 3 commands

```bash
# 1. Clone repository
git clone https://github.com/1nk1/claude-flow-docker.git
cd claude-flow-docker

# 2. Setup and start
make setup
make start

# 3. Connect to your project
cp config/.claude/settings.json /path/to/your/project/.claude/
```

### Verify it works

```bash
# Check status
make status

# Check versions
./cf-exec.sh node --version        # v22.x.x
./cf-exec.sh claude-flow --version # v2.5.0-alpha

# First command
./cf-exec.sh claude-flow hive-mind status
```

## 📚 Documentation

| Document | Description |
|----------|-------------|
| [QUICKSTART.md](QUICKSTART.md) | ⚡ Get started in 3 minutes |
| [INSTALLATION.md](INSTALLATION.md) | 📖 Complete installation guide |
| [INTEGRATION.md](INTEGRATION.md) | 💡 Claude Code integration examples |
| [TROUBLESHOOTING.md](TROUBLESHOOTING.md) | 🔧 Common issues and solutions |
| [PROJECT_SUMMARY.md](PROJECT_SUMMARY.md) | 📊 Project overview |

## 🎮 Main Commands

### Container Management

```bash
make start              # Start container
make stop               # Stop container
make restart            # Restart container
make status             # Check status
make logs               # View logs
make shell              # Interactive shell
make clean              # Stop and remove container
```

### Claude-Flow Commands

```bash
# Hive-Mind
make hive-spawn TASK="build REST API"

# Swarm (quick command)
make swarm TASK="implement feature"

# Memory
make memory-stats
make memory-query Q="search term"

# Utilities
make backup             # Create backup
make restore BACKUP=file.tar.gz
```

### Direct Execution

```bash
./cf-exec.sh claude-flow hive-mind spawn "task" --claude
./cf-exec.sh claude-flow swarm "task" --claude
./cf-exec.sh claude-flow memory stats
```

## 🔗 Claude Code Integration

### 1. Setup Project

```bash
cd your-project
mkdir -p .claude
cp /path/to/claude-flow-docker/config/.claude/settings.json ./.claude/
```

### 2. Usage

```bash
# Make sure container is running
docker ps | grep claude-flow

# Start Claude Code
claude
```

### 3. Verify Connection

In Claude Code:
```
Claude, using Claude-Flow from Docker, show me the hive-mind status
```

Claude automatically uses MCP tools from the Docker container! 🎉

## 🏗️ Project Structure

```
claude-flow-docker/
├── .github/                    # GitHub Actions workflows
│   ├── workflows/
│   │   ├── docker-build.yml   # Build and test Docker image
│   │   └── docs.yml           # Documentation checks
│   └── ISSUE_TEMPLATE/        # Issue templates
├── config/                     # Configuration
│   └── .claude/
│       └── settings.json      # MCP configuration
├── tests/                      # Test scripts
│   ├── test-docker-build.sh
│   ├── test-mcp-connection.sh
│   └── test-claude-flow.sh
├── docs/                       # Additional documentation
├── Dockerfile                  # Node.js 22 + Claude-Flow
├── docker-compose.yml          # Orchestration
├── docker-entrypoint.sh        # Entrypoint script
├── Makefile                    # 20+ commands
├── .env.example                # Environment variables
├── .dockerignore               # Docker ignore rules
├── .gitignore                  # Git ignore rules
├── LICENSE                     # MIT License
└── *.sh                        # Management scripts
```

## 🧪 Testing

```bash
# Run all tests
make test

# CI/CD tests (same as GitHub Actions)
./tests/test-docker-build.sh
./tests/test-mcp-connection.sh
./tests/test-claude-flow.sh
```

## 🚀 CI/CD

GitHub Actions automatically:
- ✅ Builds Docker image
- ✅ Checks Node.js 22
- ✅ Tests Claude-Flow installation
- ✅ Verifies MCP connection
- ✅ Validates documentation
- ✅ Runs integration tests

## 🐛 Troubleshooting

### Issue: better-sqlite3 error

```bash
chmod +x fix-node22.sh
./fix-node22.sh
make clean && make build && make start
```

### Issue: MCP servers not connecting

```bash
# Check container is running
docker ps | grep claude-flow

# Restart container
make restart

# Verify MCP config
cat .claude/settings.json
```

### Issue: Permission denied

```bash
chmod +x *.sh docker-entrypoint.sh
```

See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for more solutions.

## 📊 Performance

- **84.8% SWE-Bench** solve rate
- **32.3% token reduction** through efficient context management
- **2.8-4.4x speed** improvement via parallel coordination
- **64 specialized agents** for complete development ecosystem
- **87 MCP tools** for comprehensive automation

## 🤝 Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Claude-Flow](https://github.com/ruvnet/claude-flow) by [@ruvnet](https://github.com/ruvnet)
- [Anthropic Claude](https://www.anthropic.com/claude) for AI capabilities
- [Docker](https://www.docker.com/) for containerization

## 📮 Support

- 🐛 [Report Bug](https://github.com/1nk1/claude-flow-docker/issues)
- 💡 [Request Feature](https://github.com/1nk1/claude-flow-docker/issues)
- 📖 

## ⭐ Star History

[![Star History Chart](https://api.star-history.com/svg?repos=1nk1/claude-flow-docker&type=Date)](https://star-history.com/#1nk1/claude-flow-docker&Date)

---

**Built with ❤️ for isolated AI development with Claude-Flow**

**Version:** 1.0.0  
**Status:** Production Ready  
**Maintained:** Yes
