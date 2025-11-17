# 🔗 Integration Guide

Complete guide for integrating Claude-Flow Docker with Claude Code and other tools.

## 🎯 Claude Code Integration

### Quick Setup

```bash
# 1. Ensure container is running
docker ps | grep claude-flow

# 2. Copy MCP config to your project
cd your-project
mkdir -p .claude
cp /path/to/claude-flow-docker/config/.claude/settings.json ./.claude/

# 3. Start Claude Code
claude
```

### MCP Configuration Explained

The `settings.json` configures 4 MCP servers:

#### 1. claude-flow-docker (Main)
```json
{
  "command": "docker",
  "args": ["exec", "-i", "claude-flow-alpha", "npx", "claude-flow", "mcp"],
  "env": {}
}
```
**Purpose:** Main Claude-Flow orchestration via Docker

#### 2. claude-flow-swarm
```json
{
  "command": "docker",
  "args": ["exec", "-i", "claude-flow-alpha", "npx", "claude-flow", "swarm"],
  "env": {}
}
```
**Purpose:** Quick swarm commands

#### 3. claude-flow-memory
```json
{
  "command": "docker",
  "args": ["exec", "-i", "claude-flow-alpha", "npx", "claude-flow", "memory"],
  "env": {}
}
```
**Purpose:** Memory system access

#### 4. claude-flow-hive
```json
{
  "command": "docker",
  "args": ["exec", "-i", "claude-flow-alpha", "npx", "claude-flow", "hive-mind"],
  "env": {}
}
```
**Purpose:** Hive-mind coordination

### Hooks Configuration

4 hooks for automated workflows:

1. **preEditHook** - Validates and prepares before editing
2. **postEditHook** - Auto-formats after editing  
3. **sessionStartHook** - Restores context on start
4. **sessionEndHook** - Saves state on end

## 💡 Usage Examples

### Example 1: Create REST API

```bash
# In Claude Code:
Claude, using Claude-Flow from Docker, create a REST API with:
- Express.js
- User authentication
- MongoDB
- JWT tokens
```

Claude will:
1. Spawn hive-mind with appropriate agents
2. Create project structure
3. Implement features
4. Run tests
5. Store memory

### Example 2: Debug Code

```bash
# In Claude Code with file open:
Claude, analyze this code for bugs and suggest fixes
```

Hooks automatically:
1. **preEditHook** - Validates file
2. Claude analyzes and suggests
3. **postEditHook** - Auto-formats changes

### Example 3: Research Task

```bash
Claude, research best practices for React performance optimization
```

Claude-Flow:
1. Uses research agents
2. Gathers information
3. Stores in memory
4. Generates report

### Example 4: Multi-File Project

```bash
Claude, create a Next.js app with:
- TypeScript
- Tailwind CSS
- Authentication
- Database integration
```

Hive-mind coordinates:
- Frontend agents
- Backend agents
- Database agents
- Test agents

## 🔧 Advanced Integration

### Custom MCP Server

Add your own MCP server:

```json
{
  "mcpServers": {
    "my-custom-tool": {
      "command": "docker",
      "args": ["exec", "-i", "claude-flow-alpha", "npx", "my-tool"],
      "env": {
        "CUSTOM_VAR": "value"
      }
    }
  }
}
```

### Environment Variables

Pass environment variables to container:

```bash
# In .env file
MY_API_KEY=your-key
MY_CONFIG=value

# In docker-compose.yml
environment:
  - MY_API_KEY=${MY_API_KEY}
  - MY_CONFIG=${MY_CONFIG}
```

### Volume Mounts

Mount additional directories:

```yaml
volumes:
  - ./project:/workspace/project
  - ./custom-data:/workspace/data:ro  # Read-only
  - ~/.ssh:/root/.ssh:ro               # SSH keys
```

## 🎮 IDE Integration

### VS Code

Install Claude Code extension and configure MCP:

```json
// .vscode/settings.json
{
  "claude.mcpServers": {
    "claude-flow-docker": {
      "command": "docker",
      "args": ["exec", "-i", "claude-flow-alpha", "npx", "claude-flow", "mcp"]
    }
  }
}
```

### JetBrains IDEs

Use terminal integration:

```bash
# In IDE terminal
claude

# Claude Code connects to Docker automatically
```

## 🔄 CI/CD Integration

### GitHub Actions

```yaml
- name: Setup Claude-Flow Docker
  run: |
    docker compose up -d
    sleep 10

- name: Run AI-powered tests
  run: |
    docker exec claude-flow-alpha npx claude-flow test
```

### GitLab CI

```yaml
claude-flow:
  image: docker:latest
  services:
    - docker:dind
  script:
    - docker compose up -d
    - docker exec claude-flow-alpha npx claude-flow analyze
```

## 📊 Monitoring Integration

### Logging

Access logs in real-time:

```bash
# Follow logs
make logs

# Or Docker Compose
docker compose logs -f claude-flow

# Specific service
docker logs -f claude-flow-alpha
```

### Metrics

Export metrics:

```bash
# Container stats
docker stats claude-flow-alpha

# Memory usage
docker exec claude-flow-alpha claude-flow memory stats
```

## 🔐 Security Integration

### SSH Keys

Mount SSH keys for git operations:

```yaml
volumes:
  - ~/.ssh:/root/.ssh:ro
```

### Secrets Management

Use Docker secrets:

```yaml
secrets:
  api_key:
    file: ./secrets/api_key.txt

services:
  claude-flow:
    secrets:
      - api_key
```

## 🌐 Network Integration

### Access from Host

Expose ports if needed:

```yaml
ports:
  - "3000:3000"  # Application port
  - "8080:8080"  # API port
```

### Connect to Other Containers

Use Docker networks:

```yaml
networks:
  app-network:
    driver: bridge

services:
  claude-flow:
    networks:
      - app-network
  
  database:
    networks:
      - app-network
```

## 📦 Package Managers Integration

### npm/yarn

Install packages in container:

```bash
# Via Make
make install-package PKG="axios typescript"

# Via Docker exec
docker exec claude-flow-alpha npm install axios
```

### pip

Install Python packages:

```bash
docker exec claude-flow-alpha pip install pandas numpy
```

## 🧪 Testing Integration

### Run Tests

```bash
# All tests
make test

# Specific test
./tests/test-mcp-connection.sh

# Inside container
docker exec claude-flow-alpha npm test
```

### Test with Claude

```bash
# In Claude Code:
Claude, run all tests and analyze failures
```

## 🔄 Workflow Examples

### Daily Development Workflow

```bash
# Morning: Start
make start

# Work with Claude Code
claude

# Evening: Backup and stop
make backup
make stop
```

### Team Collaboration

```bash
# Share configuration
git add .claude/settings.json
git commit -m "Add Claude-Flow MCP config"
git push

# Team members:
git pull
cp .claude/settings.json ~/.claude/
```

### Production Deployment

```bash
# Build production image
docker build -t claude-flow:prod .

# Deploy
docker run -d \
  --name claude-flow-prod \
  --restart unless-stopped \
  -v $(pwd)/data:/workspace/data \
  claude-flow:prod
```

## 🆘 Integration Troubleshooting

### MCP Not Connecting

```bash
# Check container
docker ps | grep claude-flow

# Test MCP manually
echo '{"jsonrpc":"2.0","id":1,"method":"initialize"}' | \
  docker exec -i claude-flow-alpha npx claude-flow mcp

# Verify config
cat .claude/settings.json
```

### Hooks Not Working

```bash
# Check hooks config
cat .claude/settings.json | jq '.hooks'

# Test hook manually
docker exec claude-flow-alpha npx claude-flow hooks pre-edit --file test.js
```

### Performance Issues

```bash
# Check resources
docker stats claude-flow-alpha

# Increase limits in docker-compose.yml
mem_limit: 8g
cpus: 4.0
```

## 📚 Related Resources

- [INSTALLATION.md](INSTALLATION.md) - Setup guide
- [QUICKSTART.md](QUICKSTART.md) - Quick start
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - Common issues
- [Claude-Flow Wiki](https://github.com/ruvnet/claude-flow/wiki) - Upstream docs

---

**Ready to integrate! 🔗**
