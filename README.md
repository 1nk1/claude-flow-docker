# 🐳 Claude-Flow Docker

<div align="center">

[![🌟 Star on GitHub](https://img.shields.io/github/stars/ruvnet/claude-flow?style=for-the-badge&logo=github&color=gold)](https://github.com/ruvnet/claude-flow)
[![📈 Downloads](https://img.shields.io/npm/dt/claude-flow?style=for-the-badge&logo=npm&color=blue&label=Downloads)](https://www.npmjs.com/package/claude-flow)
[![📦 Latest Release](https://img.shields.io/npm/v/claude-flow/alpha?style=for-the-badge&logo=npm&color=green&label=v2.7.0-alpha.10)](https://www.npmjs.com/package/claude-flow)
[![⚡ Claude Code](https://img.shields.io/badge/Claude%20Code-SDK%20Integrated-green?style=for-the-badge&logo=anthropic)](https://github.com/ruvnet/claude-flow)
[![🏛️ Agentics Foundation](https://img.shields.io/badge/Agentics-Foundation-crimson?style=for-the-badge&logo=openai)](https://discord.com/invite/dfxmpwkG2D)
[![🛡️ MIT License](https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge&logo=opensourceinitiative)](https://opensource.org/licenses/MIT)

</div>

## 🌟 **Overview**

**Claude-Flow v2.7** is an enterprise-grade AI orchestration platform that combines **hive-mind swarm intelligence**, **persistent memory**, and **100+ advanced MCP tools** to revolutionize AI-powered development workflows.

### 🎯 **Key Features**

- **🎨 25 Claude Skills**: Natural language-activated skills for development, GitHub, memory, and automation
- **🚀 AgentDB v1.3.9 Integration**: 96x-164x faster vector search with semantic understanding (PR #830)
- **🧠 Hybrid Memory System**: AgentDB + ReasoningBank with automatic fallback
- **🔍 Semantic Vector Search**: HNSW indexing (O(log n)) + 9 RL algorithms
- **🐝 Hive-Mind Intelligence**: Queen-led AI coordination with specialized worker agents
- **🔧 100 MCP Tools**: Comprehensive toolkit for swarm orchestration and automation
- **🔄 Dynamic Agent Architecture (DAA)**: Self-organizing agents with fault tolerance
- **💾 Persistent Memory**: 150x faster search, 4-32x memory reduction (quantization)
- **🪝 Advanced Hooks System**: Automated workflows with pre/post operation hooks
- **📊 GitHub Integration**: 6 specialized modes for repository management
- **🌐 Flow Nexus Cloud**: E2B sandboxes, AI swarms, challenges, and marketplace

> 🔥 **Revolutionary AI Coordination**: Build faster, smarter, and more efficiently with AI-powered development orchestration
>
> 🆕 **NEW: AgentDB Integration**: 96x-164x performance boost with semantic vector search, reflexion memory, and skill library auto-consolidation



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

# Check container logs
docker logs claude-flow-alpha

# View application logs
docker exec claude-flow-alpha tail -f /workspace/logs/claude-flow.log

# Test claude-flow
docker exec -it claude-flow-alpha claude-flow --version
```

## 📚 Documentation

### Getting Started
- [Quick Start](docs/getting-started/quick-start.md) - ⚡ Get started in 3 minutes
- [Installation Guide](docs/getting-started/INSTALLATION.md) - 📖 Complete installation guide
- [Troubleshooting](docs/getting-started/TROUBLESHOOTING.md) - 🔧 Common issues and solutions

### Guides
- [Deployment Guide](docs/guides/DEPLOYMENT.md) - 🚀 Production deployment
- [Integration Guide](docs/guides/INTEGRATION.md) - 💡 Claude Code integration examples
- [Logging System](docs/guides/LOGGING.md) - 📊 Comprehensive logging guide

### MCP Integration
- [MCP Setup](docs/mcp/README.md) - 🔌 MCP server setup and usage
- [MCP Connection](docs/mcp/connection.md) - 🔗 Detailed connection guide

### Development
- [Contributing](docs/development/CONTRIBUTING.md) - 🤝 How to contribute

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
docker exec -it claude-flow-alpha claude-flow hive-mind spawn "task" --claude
docker exec -it claude-flow-alpha claude-flow swarm "task" --claude
docker exec -it claude-flow-alpha claude-flow memory stats
```

### Logging

```bash
# View real-time logs
docker logs -f claude-flow-alpha

# Application logs
docker exec claude-flow-alpha tail -f /workspace/logs/claude-flow.log

# Log statistics
docker exec claude-flow-alpha bash -c "source /workspace/lib/logger.sh && log_stats"

# Search for errors
docker exec claude-flow-alpha grep ERROR /workspace/logs/claude-flow.log
```

See [Logging Guide](docs/guides/LOGGING.md) for complete logging documentation.

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
├── config/                     # Configuration templates
│   └── .claude/               # Claude-Flow MCP configuration
│       ├── agents/            # 75+ agent templates
│       ├── commands/          # 150+ command files
│       ├── helpers/           # Helper scripts
│       ├── settings/          # Settings files
│       └── system-prompts/    # System prompts
├── project/                    # Project workspace
│   ├── .claude -> ../config/.claude  # Symlink to config
│   └── memory/                # Persistent memory storage
├── docs/                       # Documentation
│   ├── getting-started/       # Quick start guides
│   ├── guides/                # Comprehensive guides
│   ├── mcp/                   # MCP integration docs
│   └── development/           # Development guides
├── scripts/                    # Utility scripts
│   ├── setup.sh
│   ├── connect-mcp.sh
│   ├── switch-project.sh
│   └── view-logs.sh
├── tests/                      # Test scripts
│   ├── test-docker-build.sh
│   ├── test-mcp-connection.sh
│   └── test-claude-flow.sh
├── docker/                     # Docker utilities
│   ├── update-claude-code.sh
│   ├── rollback-claude-code.sh
│   └── check-claude-versions.sh
├── lib/                        # Libraries
│   └── logger.sh              # Logging library
├── logs/                       # Log files
│   └── claude-flow.log
├── Dockerfile                  # Node.js 22 + Claude-Flow
├── docker-compose.yml          # Orchestration
├── docker-entrypoint.sh        # Container entrypoint
├── Makefile                    # 20+ commands
├── .env.example                # Environment variables
└── README.md                   # This file
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

See [Troubleshooting Guide](docs/getting-started/TROUBLESHOOTING.md) for more solutions.

## 📊 Performance

- **84.8% SWE-Bench** solve rate
- **32.3% token reduction** through efficient context management
- **2.8-4.4x speed** improvement via parallel coordination
- **64 specialized agents** for complete development ecosystem
- **87 MCP tools** for comprehensive automation

## 🤝 Contributing

Contributions are welcome! Please read [Contributing Guide](docs/development/CONTRIBUTING.md) for details.

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
- 📖 [Documentation](https://github.com/1nk1/claude-flow-docker/wiki)
- 💬 [Discussions](https://github.com/1nk1/claude-flow-docker)

## ⭐ Star History

[![Star History Chart](https://api.star-history.com/svg?repos=1nk1/claude-flow-docker&type=Date)](https://star-history.com/#1nk1/claude-flow-docker&Date)

---

**Built with ❤️ for isolated AI development with Claude-Flow**

**Version:** 1.0.0
**Status:** Production Ready
**Maintained:** Yes
