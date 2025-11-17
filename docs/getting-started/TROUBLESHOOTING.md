# 🔧 Troubleshooting Guide

Common issues and solutions for Claude-Flow Docker.

## 🐛 Container Issues

### Container Won't Start

**Problem:** Container fails to start or exits immediately

**Solutions:**

```bash
# 1. Check Docker is running
docker ps

# 2. Check logs
docker logs claude-flow-alpha

# 3. Clean and rebuild
make clean
make build
make start

# 4. Check for port conflicts
docker ps -a
```

### Container Keeps Restarting

**Problem:** Container is in restart loop

**Solutions:**

```bash
# Check what's wrong
docker logs claude-flow-alpha --tail 50

# Disable healthcheck temporarily
# Edit docker-compose.yml and comment out healthcheck

# Start without auto-restart
docker compose up claude-flow

# Check entrypoint script
docker exec claude-flow-alpha cat /usr/local/bin/docker-entrypoint.sh
```

### Out of Memory

**Problem:** Container crashes with OOM

**Solutions:**

```bash
# Increase memory limit in docker-compose.yml
mem_limit: 8g  # Increase from 4g

# Or via docker run
docker run -m 8g ...

# Check current usage
docker stats claude-flow-alpha
```

## 🔌 MCP Connection Issues

### MCP Server Not Responding

**Problem:** Claude Code can't connect to MCP server

**Solutions:**

```bash
# 1. Verify container is running
docker ps | grep claude-flow

# 2. Test MCP manually
echo '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{}}' | \
  docker exec -i claude-flow-alpha npx claude-flow mcp

# 3. Check MCP config
cat .claude/settings.json

# 4. Restart container
make restart
```

### "command not found" Error

**Problem:** `docker: command not found` in MCP config

**Solutions:**

```bash
# Check Docker is in PATH
which docker

# Add to PATH if needed
export PATH=$PATH:/usr/local/bin

# Or use full path in settings.json
"command": "/usr/local/bin/docker"
```

### stdin/stdout Issues

**Problem:** MCP communication fails

**Solutions:**

```bash
# Test stdin/stdout
echo "test" | docker exec -i claude-flow-alpha cat

# Check container accepts stdin
docker exec -i claude-flow-alpha npx --version

# Restart with fresh config
docker compose down
docker compose up -d
```

## 💾 Storage Issues

### SQLite Database Locked

**Problem:** "database is locked" error

**Solutions:**

```bash
# Stop container
make stop

# Remove lock files
docker compose run --rm claude-flow rm -f /workspace/.swarm/*.lock

# Restart
make start

# Or backup and reinit
make backup
./cf-exec.sh claude-flow init --force
```

### Data Not Persisting

**Problem:** Data lost after container restart

**Solutions:**

```bash
# Check volumes in docker-compose.yml
docker volume ls
docker volume inspect claude-flow-docker_project

# Ensure volumes are mounted
volumes:
  - ./project:/workspace/project
  - ./backups:/workspace/backups

# Test persistence
docker exec claude-flow-alpha touch /workspace/test.txt
docker compose restart
docker exec claude-flow-alpha ls /workspace/test.txt
```

### Disk Space Full

**Problem:** No space left on device

**Solutions:**

```bash
# Check Docker disk usage
docker system df

# Clean up
docker system prune -a --volumes

# Remove old images
docker image prune -a

# Check host disk space
df -h
```

## 🔨 Build Issues

### better-sqlite3 Build Fails

**Problem:** npm install fails for better-sqlite3

**Solutions:**

```bash
# Use pre-built solution
./fix-node22.sh

# Or rebuild from source
docker compose run --rm claude-flow \
  npm install -g better-sqlite3 --build-from-source --force

# Check build tools
docker exec claude-flow-alpha which gcc python3 make
```

### Docker Build Timeout

**Problem:** Build takes too long or times out

**Solutions:**

```bash
# Increase timeout
DOCKER_CLIENT_TIMEOUT=300 docker compose build

# Use buildkit
DOCKER_BUILDKIT=1 docker build -t claude-flow .

# Build with more resources
docker build --memory 8g --cpus 4 -t claude-flow .
```

### npm Install Fails

**Problem:** npm packages fail to install

**Solutions:**

```bash
# Clear npm cache
docker compose run --rm claude-flow npm cache clean --force

# Use different registry
docker compose run --rm claude-flow \
  npm install --registry https://registry.npmmirror.com

# Install with legacy peer deps
docker compose run --rm claude-flow \
  npm install --legacy-peer-deps
```

## 🚀 Performance Issues

### Slow Container

**Problem:** Container is very slow

**Solutions:**

```bash
# Check resource usage
docker stats claude-flow-alpha

# Increase resources in docker-compose.yml
cpus: 4.0
mem_limit: 8g

# Check host system
top
free -h

# Disable unnecessary services
# Comment out healthcheck if not needed
```

### High CPU Usage

**Problem:** Container uses too much CPU

**Solutions:**

```bash
# Limit CPU
docker update --cpus="2.0" claude-flow-alpha

# Check what's running
docker exec claude-flow-alpha ps aux

# Check for infinite loops in scripts
docker logs claude-flow-alpha | grep -i error
```

## 📝 Claude-Flow Specific Issues

### Hive-Mind Won't Start

**Problem:** `claude-flow hive-mind spawn` fails

**Solutions:**

```bash
# Initialize first
./cf-exec.sh claude-flow init --force

# Check directories exist
./cf-exec.sh ls -la /workspace/.hive-mind

# Clear old sessions
./cf-exec.sh rm -rf /workspace/.hive-mind/*

# Start fresh
./cf-exec.sh claude-flow hive-mind spawn "test" --claude
```

### Memory System Errors

**Problem:** Memory queries fail

**Solutions:**

```bash
# Check database
./cf-exec.sh ls -la /workspace/.swarm/memory.db

# Reinitialize
./cf-exec.sh claude-flow init --force

# Check SQLite
./cf-exec.sh sqlite3 /workspace/.swarm/memory.db ".tables"
```

### Agent Coordination Fails

**Problem:** Agents don't coordinate properly

**Solutions:**

```bash
# Check agent status
./cf-exec.sh claude-flow agent list

# Restart hive-mind
./cf-exec.sh claude-flow hive-mind stop
./cf-exec.sh claude-flow hive-mind spawn "new-task"

# Check logs
make logs | grep -i agent
```

## 🔐 Permission Issues

### Permission Denied Errors

**Problem:** Scripts can't execute

**Solutions:**

```bash
# Make scripts executable
chmod +x *.sh

# Fix all scripts
find . -name "*.sh" -exec chmod +x {} \;

# Check inside container
docker exec claude-flow-alpha ls -la /usr/local/bin/docker-entrypoint.sh
```

### Volume Mount Permission Issues

**Problem:** Can't write to mounted volumes

**Solutions:**

```bash
# Check volume permissions
ls -la project/

# Fix permissions
sudo chown -R $USER:$USER project/

# Or run container as current user
# In docker-compose.yml:
user: "${UID}:${GID}"
```

## 🌐 Network Issues

### Can't Reach Internet

**Problem:** Container has no internet access

**Solutions:**

```bash
# Check Docker network
docker network ls
docker network inspect bridge

# Test from container
docker exec claude-flow-alpha ping -c 3 google.com

# Restart Docker daemon
sudo systemctl restart docker

# Use host network (temporary)
docker run --network host ...
```

### Port Already in Use

**Problem:** Port conflict

**Solutions:**

```bash
# Find what's using the port
sudo lsof -i :3000
sudo netstat -tulpn | grep 3000

# Kill process
kill -9 <PID>

# Or use different port in docker-compose.yml
ports:
  - "3001:3000"
```

## 🖥️ Platform-Specific Issues

### Windows WSL2 Issues

**Problem:** Issues on Windows with WSL2

**Solutions:**

```bash
# Update WSL2
wsl --update

# Restart WSL
wsl --shutdown

# Use Linux line endings
git config --global core.autocrlf input

# Convert files
dos2unix *.sh
```

### macOS Silicon (M1/M2) Issues

**Problem:** ARM architecture issues

**Solutions:**

```bash
# Use ARM-compatible base image (already done)
FROM node:22-alpine  # Works on ARM

# Force platform
docker build --platform linux/amd64 -t claude-flow .

# Or use native ARM
docker build --platform linux/arm64 -t claude-flow .
```

### Linux Specific Issues

**Problem:** SELinux or AppArmor blocking

**Solutions:**

```bash
# Check SELinux
getenforce

# Temporarily disable (testing only)
sudo setenforce 0

# Add Docker to SELinux
sudo setsebool -P docker_transition_enabled 1
```

## 📋 Diagnostic Commands

### Complete Health Check

```bash
#!/bin/bash
echo "=== Docker Health Check ==="
docker --version
docker compose version
docker ps | grep claude-flow
echo ""

echo "=== Container Health ==="
docker inspect claude-flow-alpha | jq '.[0].State'
echo ""

echo "=== Resource Usage ==="
docker stats --no-stream claude-flow-alpha
echo ""

echo "=== Logs (last 20 lines) ==="
docker logs --tail 20 claude-flow-alpha
echo ""

echo "=== Claude-Flow Status ==="
docker exec claude-flow-alpha claude-flow --version
docker exec claude-flow-alpha node --version
echo ""

echo "=== MCP Test ==="
echo '{"jsonrpc":"2.0","id":1,"method":"initialize"}' | \
  docker exec -i claude-flow-alpha npx claude-flow mcp
```

Save as `health-check.sh` and run: `chmod +x health-check.sh && ./health-check.sh`

## 🆘 Getting Help

### Collect Debug Information

```bash
# Save to file
{
  echo "=== System Info ==="
  uname -a
  docker --version
  docker compose version
  
  echo -e "\n=== Container Status ==="
  docker ps -a
  
  echo -e "\n=== Container Logs ==="
  docker logs claude-flow-alpha --tail 100
  
  echo -e "\n=== Docker Inspect ==="
  docker inspect claude-flow-alpha
  
  echo -e "\n=== Disk Space ==="
  df -h
  docker system df
} > debug-info.txt
```

### Create GitHub Issue

Include:
1. Output of `debug-info.txt`
2. Your `docker-compose.yml`
3. Your `.env` file (remove secrets!)
4. Steps to reproduce
5. Expected vs actual behavior

### Community Support

- [GitHub Issues](https://github.com/1nk1/claude-flow-docker/issues)
- [GitHub Discussions](https://github.com/1nk1/claude-flow-docker)
- [Claude-Flow Wiki](https://github.com/ruvnet/claude-flow/wiki)

---

**Still having issues? Create an issue with debug info!** 🆘
