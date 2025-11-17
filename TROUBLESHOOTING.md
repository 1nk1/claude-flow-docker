# Troubleshooting Guide

Common issues and solutions for Claude-Flow Docker.

## Quick Diagnosis

Run the diagnostic script:

```bash
make status
docker logs claude-flow-alpha --tail 100
```

## Container Issues

### Container Won't Start

**Symptoms**: `docker-compose up -d` fails or container exits immediately

**Solutions**:

1. Check logs:
   ```bash
   docker logs claude-flow-alpha
   ```

2. Rebuild:
   ```bash
   make clean
   make build
   make start
   ```

3. Check ports:
   ```bash
   lsof -i :8811
   # Kill process using port if needed
   ```

4. Verify Docker:
   ```bash
   docker --version
   docker-compose --version
   ```

### Container Keeps Restarting

**Symptoms**: Container starts then stops repeatedly

**Solutions**:

1. Check resource limits in `.env`:
   ```bash
   CONTAINER_MEMORY_LIMIT=4G  # Increase if needed
   ```

2. View crash logs:
   ```bash
   docker logs claude-flow-alpha --tail 200
   ```

3. Check entrypoint:
   ```bash
   docker exec claude-flow-alpha bash -c "which docker-entrypoint.sh"
   ```

### Permission Denied

**Symptoms**: Cannot execute scripts or access files

**Solutions**:

1. Fix script permissions:
   ```bash
   chmod +x *.sh scripts/*.sh
   ```

2. Fix ownership:
   ```bash
   sudo chown -R $USER:$USER .
   ```

3. On Linux, add user to docker group:
   ```bash
   sudo usermod -aG docker $USER
   newgrp docker
   ```

## Claude-Flow Issues

### Claude-Flow Not Found

**Symptoms**: `claude-flow: command not found`

**Solutions**:

1. Check installation:
   ```bash
   docker exec claude-flow-alpha which claude-flow
   docker exec claude-flow-alpha npm list -g | grep claude-flow
   ```

2. Reinstall:
   ```bash
   docker exec claude-flow-alpha npm install -g claude-flow@alpha
   ```

3. Check PATH:
   ```bash
   docker exec claude-flow-alpha echo $PATH
   ```

### Memory Database Error

**Symptoms**: SQLite or memory errors

**Solutions**:

1. Reinitialize:
   ```bash
   docker exec claude-flow-alpha claude-flow init --force
   ```

2. Check database:
   ```bash
   docker exec claude-flow-alpha ls -la /workspace/.swarm/memory.db
   ```

3. Fix permissions:
   ```bash
   docker exec claude-flow-alpha chown appuser:appgroup /workspace/.swarm/memory.db
   ```

### Agent Visualization Not Working

**Symptoms**: No colors or agents not displayed

**Solutions**:

1. Check agent logger:
   ```bash
   docker exec claude-flow-alpha ls -la /workspace/lib/agent-logger.sh
   ```

2. Test manually:
   ```bash
   docker exec claude-flow-alpha bash -c 'source /workspace/lib/agent-logger.sh && log_agent_start 0 "Test" "coordinator"'
   ```

3. Check logs:
   ```bash
   docker exec claude-flow-alpha tail -50 /workspace/logs/agents.log
   ```

## MCP Issues

### MCP Server Not Connecting

**Symptoms**: Claude Code can't connect to MCP server

**Solutions**:

1. Verify container running:
   ```bash
   docker ps | grep claude-flow
   ```

2. Check MCP config:
   ```bash
   cat config/.claude/settings.json
   ```

3. Test MCP connection:
   ```bash
   docker exec -i claude-flow-alpha npx claude-flow@alpha mcp --help
   ```

4. Restart container:
   ```bash
   make restart
   ```

### MCP Tools Not Available

**Symptoms**: Claude Code doesn't show MCP tools

**Solutions**:

1. Verify settings.json in project:
   ```bash
   ls -la your-project/.claude/settings.json
   ```

2. Check Claude Code config:
   ```bash
   cat ~/.config/claude/settings.json
   ```

3. Restart Claude Code:
   ```bash
   # Close Claude Code and restart
   claude
   ```

### MCP Timeout

**Symptoms**: Connection timeout errors

**Solutions**:

1. Increase timeout in settings.json:
   ```json
   {
     "mcpServers": {
       "claude-flow": {
         "timeout": 30000
       }
     }
   }
   ```

2. Check container resources:
   ```bash
   docker stats claude-flow-alpha
   ```

## Build Issues

### Build Fails

**Symptoms**: `docker-compose build` errors

**Solutions**:

1. Clean Docker cache:
   ```bash
   docker system prune -a
   ```

2. Remove volumes:
   ```bash
   docker volume ls | grep claude-flow
   docker volume rm claude-flow-hive claude-flow-swarm
   ```

3. Rebuild from scratch:
   ```bash
   make clean
   docker-compose build --no-cache
   ```

### npm Install Fails

**Symptoms**: Package installation errors during build

**Solutions**:

1. Check internet connection

2. Use different npm registry:
   ```dockerfile
   RUN npm config set registry https://registry.npmjs.org/
   RUN npm install -g claude-flow@alpha
   ```

3. Clear npm cache in Dockerfile:
   ```dockerfile
   RUN npm cache clean --force
   ```

### Out of Disk Space

**Symptoms**: "No space left on device"

**Solutions**:

1. Check disk usage:
   ```bash
   df -h
   docker system df
   ```

2. Clean Docker:
   ```bash
   docker system prune -a --volumes
   ```

3. Remove unused images:
   ```bash
   docker images
   docker rmi <image-id>
   ```

## Performance Issues

### Container Slow

**Symptoms**: Slow response times

**Solutions**:

1. Increase resources in `.env`:
   ```bash
   CONTAINER_CPU_LIMIT=4
   CONTAINER_MEMORY_LIMIT=8G
   ```

2. Check stats:
   ```bash
   docker stats claude-flow-alpha
   ```

3. Restart Docker:
   ```bash
   # On macOS/Windows: Restart Docker Desktop
   # On Linux:
   sudo systemctl restart docker
   ```

### Memory Leak

**Symptoms**: Memory usage grows over time

**Solutions**:

1. Monitor memory:
   ```bash
   watch docker stats claude-flow-alpha
   ```

2. Restart container regularly:
   ```bash
   make restart
   ```

3. Check logs for errors:
   ```bash
   docker logs claude-flow-alpha | grep -i "memory\|oom"
   ```

## Logging Issues

### No Logs Visible

**Symptoms**: Log files empty or not created

**Solutions**:

1. Check log directory:
   ```bash
   docker exec claude-flow-alpha ls -la /workspace/logs/
   ```

2. Check permissions:
   ```bash
   docker exec claude-flow-alpha bash -c 'touch /workspace/logs/test.log && ls -la /workspace/logs/test.log'
   ```

3. View container logs directly:
   ```bash
   docker logs claude-flow-alpha
   ```

### Logs Too Large

**Symptoms**: Log files consuming too much disk

**Solutions**:

1. Rotate logs:
   ```bash
   docker exec claude-flow-alpha bash -c 'echo "" > /workspace/logs/claude-flow.log'
   ```

2. Configure log rotation in `docker-compose.yml`:
   ```yaml
   logging:
     driver: "json-file"
     options:
       max-size: "10m"
       max-file: "3"
   ```

## Network Issues

### Port Already in Use

**Symptoms**: "port is already allocated"

**Solutions**:

1. Find process:
   ```bash
   lsof -i :8811
   ```

2. Kill process:
   ```bash
   kill -9 <PID>
   ```

3. Change port in `docker-compose.yml`:
   ```yaml
   ports:
     - "8812:8811"
   ```

### Cannot Reach Container

**Symptoms**: Connection refused

**Solutions**:

1. Check if running:
   ```bash
   docker ps | grep claude-flow
   ```

2. Check network:
   ```bash
   docker network ls | grep claude-flow
   docker network inspect claude-flow-network
   ```

3. Recreate network:
   ```bash
   make clean
   make start
   ```

## Platform-Specific Issues

### macOS M1/M2/M4

**Issue**: Architecture mismatch or slow build

**Solutions**:

1. Ensure using ARM64 images:
   ```dockerfile
   FROM node:22-slim  # Auto-detects ARM
   ```

2. Enable Rosetta in Docker Desktop settings

3. Use native ARM Node.js

### Linux

**Issue**: Permission denied without sudo

**Solutions**:

```bash
sudo usermod -aG docker $USER
newgrp docker
```

### Windows WSL2

**Issue**: Slow file access or mount issues

**Solutions**:

1. Clone repo in WSL filesystem:
   ```bash
   cd ~
   git clone https://github.com/1nk1/claude-flow-docker.git
   ```

2. Enable WSL2 backend in Docker Desktop

3. Increase WSL memory in `.wslconfig`:
   ```ini
   [wsl2]
   memory=8GB
   ```

## Getting More Help

### Enable Debug Mode

Edit `.env`:
```bash
CLAUDE_FLOW_DEBUG=true
CLAUDE_FLOW_VERBOSE=true
CLAUDE_FLOW_LOG_LEVEL=debug
MCP_DEBUG=true
MCP_LOG_LEVEL=debug
```

Restart:
```bash
make restart
```

### Collect Diagnostic Info

```bash
# System info
uname -a
docker --version
docker-compose --version

# Container info
docker ps -a | grep claude-flow
docker logs claude-flow-alpha --tail 200

# Resource usage
docker stats --no-stream claude-flow-alpha

# Volume info
docker volume ls | grep claude-flow

# Network info
docker network ls | grep claude-flow
```

### Report Issue

When reporting issues, include:

1. System info (OS, Docker version)
2. Error messages from logs
3. Steps to reproduce
4. Output of `make status`

Create issue at: https://github.com/1nk1/claude-flow-docker/issues

## Emergency Recovery

### Complete Reset

```bash
# Stop everything
make clean

# Remove all volumes (CAUTION: Deletes data)
make clean-volumes

# Clean Docker system
docker system prune -a --volumes

# Rebuild
make build
make start
```

### Backup Before Reset

```bash
# Backup volumes
docker run --rm \
  -v claude-flow-swarm:/data \
  -v $(pwd)/backup:/backup \
  alpine tar czf /backup/swarm-backup.tar.gz -C /data .

docker run --rm \
  -v claude-flow-hive:/data \
  -v $(pwd)/backup:/backup \
  alpine tar czf /backup/hive-backup.tar.gz -C /data .
```

## Still Having Issues?

1. Check [README.md](README.md) for documentation
2. Review [INSTALLATION.md](INSTALLATION.md) for setup
3. Run [demo-agents.sh](demo-agents.sh) to test
4. Create issue with diagnostic info
