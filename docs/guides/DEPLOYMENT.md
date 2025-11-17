# Deployment Guide - Claude-Flow Docker v2.0

## 🚀 Quick Deployment

For impatient users who want to get started immediately:

```bash
# 1. Rebuild container with new logging system
make clean
make build
make start

# 2. Verify logging works
make logs-stats

# 3. Watch logs in real-time
make logs-app
```

Done! Your container now has advanced logging.

## 📋 Pre-Deployment Checklist

Before deploying, ensure you have:

- [ ] Docker 20.10+ installed
- [ ] Docker Compose v2.0+ installed
- [ ] Existing `.env` file (or run `make setup`)
- [ ] Backup of important data (run `make backup`)
- [ ] 10-15 minutes for build and testing

## 🔧 Step-by-Step Deployment

### Step 1: Backup Current State

```bash
# Backup container data
make backup

# This creates: backups/claude-flow-backup-YYYYMMDD-HHMMSS.tar.gz
```

### Step 2: Stop Existing Container

```bash
# Gracefully stop
make stop

# Or force stop if needed
make kill
```

### Step 3: Update Configuration

#### Option A: Update Existing .env

Add these lines to your `.env` file:

```bash
# Logging Configuration
LOG_LEVEL=INFO
LOG_TO_FILE=true
LOG_FILE=/workspace/logs/claude-flow.log
LOG_TIMESTAMP_FORMAT=%Y-%m-%d %H:%M:%S
```

Update MCP mode (recommended):
```bash
MCP_SERVER_MODE=stdio  # Changed from tcp
```

#### Option B: Use New .env.example

```bash
# Backup current .env
cp .env .env.backup

# Copy new template
cp .env.example .env

# Edit with your settings
vim .env  # or nano, code, etc.
```

### Step 4: Build New Image

```bash
# Clean build (recommended)
make clean
make build

# Or fast build (with cache)
make build-fast
```

**Expected build time:** 2-5 minutes

### Step 5: Start Container

```bash
make start
```

You should see:
```
🚀 Starting Claude-Flow...
✅ Claude-Flow started
```

### Step 6: Verify Deployment

```bash
# Check container is running
make status

# View startup logs
docker logs claude-flow-alpha

# Check application logs created
docker exec claude-flow-alpha ls -la /workspace/logs/

# View log statistics
make logs-stats
```

### Step 7: Test Logging

```bash
# Follow application logs
make logs-app
# Press Ctrl+C to stop

# View last 100 lines
make logs-app-tail

# Check for errors (should be none)
make logs-error

# Interactive viewer
make logs-viewer
```

### Step 8: Test MCP Connection

```bash
# Check MCP is working
claude mcp list

# Should show: claude-flow: ... - ✓ Connected
```

If not connected, reconnect your project:
```bash
./connect-mcp.sh ~/your-project
```

## 🎯 Deployment Scenarios

### Scenario 1: Fresh Install

If this is a new installation:

```bash
# 1. Clone repository
git clone https://github.com/1nk1/claude-flow-docker.git
cd claude-flow-docker

# 2. Initial setup
make setup

# 3. Configure .env
vim .env  # Set your PROJECT_PATH, ANTHROPIC_API_KEY, etc.

# 4. Build and start
make build
make start

# 5. Connect to your project
./connect-mcp.sh ~/your-project

# 6. Verify
make logs-stats
```

### Scenario 2: Upgrade from Previous Version

If upgrading from an older version:

```bash
# 1. Pull latest changes
git pull origin main

# 2. Backup
make backup

# 3. Stop container
make stop

# 4. Update .env (add logging vars)
cat >> .env << 'EOF'
LOG_LEVEL=INFO
LOG_TO_FILE=true
LOG_FILE=/workspace/logs/claude-flow.log
EOF

# 5. Rebuild
make clean
make build

# 6. Start
make start

# 7. Verify
make logs-stats
```

### Scenario 3: Production Deployment

For production environment:

```bash
# 1. Set production log level
echo "LOG_LEVEL=WARN" >> .env

# 2. Enable log rotation monitoring
# Add to cron (run weekly):
# 0 0 * * 0 docker exec claude-flow-alpha bash -c "source /workspace/lib/logger.sh && log_cleanup 7"

# 3. Set up log backup
# Add to cron (run daily):
# 0 2 * * * cd /path/to/claude-flow-docker && make logs-save

# 4. Monitor resource usage
watch -n 5 'docker stats claude-flow-alpha --no-stream'

# 5. Set up alerts (optional)
# Configure monitoring tool to alert on:
# - Container restarts
# - High error rate in logs
# - Disk space (log directory)
```

### Scenario 4: Development Environment

For development:

```bash
# 1. Set debug log level
echo "LOG_LEVEL=DEBUG" >> .env

# 2. Start with verbose output
make start

# 3. Watch logs in real-time
make logs-app

# 4. Use interactive viewer for debugging
make logs-viewer
```

## 🔍 Post-Deployment Verification

### Health Checks

Run these commands to verify everything is working:

```bash
# 1. Container health
make status
# Should show: Status: Up X minutes

# 2. Logging system
make logs-stats
# Should show statistics (file size, line count, etc.)

# 3. MCP connection
claude mcp list
# Should show: ✓ Connected

# 4. Claude-Flow
docker exec -it claude-flow-alpha claude-flow --version
# Should show version number

# 5. Memory database
docker exec claude-flow-alpha ls -lh /workspace/.swarm/memory.db
# Should show database file with size

# 6. Log file
docker exec claude-flow-alpha tail -10 /workspace/logs/claude-flow.log
# Should show recent log entries
```

### Performance Checks

```bash
# Resource usage
make stats

# Processes
make top

# Detailed monitoring
make watch
```

### Log Quality Checks

```bash
# Check for errors
make logs-error

# Check for warnings
make logs-warn

# View MCP events
make logs-mcp

# Check log file size
docker exec claude-flow-alpha du -h /workspace/logs/claude-flow.log
```

## 🐛 Troubleshooting Deployment

### Issue: Build Fails

**Symptom:** `make build` fails with errors

**Solution:**
```bash
# Clear Docker cache
docker system prune -a

# Try again
make build
```

### Issue: Container Won't Start

**Symptom:** Container exits immediately after start

**Solution:**
```bash
# Check logs for errors
docker logs claude-flow-alpha

# Check .env configuration
make check-env

# Verify docker-compose config
make validate
```

### Issue: Logs Not Created

**Symptom:** Log file doesn't exist at `/workspace/logs/claude-flow.log`

**Solution:**
```bash
# Check directory permissions
docker exec claude-flow-alpha ls -la /workspace/

# Check container logs
docker logs claude-flow-alpha

# Manually create directory
docker exec claude-flow-alpha mkdir -p /workspace/logs

# Restart container
make restart
```

### Issue: Logger Library Not Found

**Symptom:** Errors about missing logger.sh

**Solution:**
```bash
# Verify file exists in host
ls -la lib/logger.sh

# Should be executable
chmod +x lib/logger.sh

# Rebuild container
make clean
make build
```

### Issue: MCP Connection Broken

**Symptom:** `claude mcp list` shows disconnected

**Solution:**
```bash
# Reconnect project
./connect-mcp.sh ~/your-project

# Restart Claude Code
# Close and reopen Claude in your project

# Verify container is running
docker ps | grep claude-flow
```

### Issue: High Log File Size

**Symptom:** Log file growing too large

**Solution:**
```bash
# Check current size
docker exec claude-flow-alpha du -h /workspace/logs/claude-flow.log

# Manual rotation
docker exec claude-flow-alpha bash -c "source /workspace/lib/logger.sh && log_rotate 10"

# Cleanup old logs
docker exec claude-flow-alpha bash -c "source /workspace/lib/logger.sh && log_cleanup 7"

# Lower log level
echo "LOG_LEVEL=WARN" >> .env
make restart
```

## 📊 Monitoring After Deployment

### Daily Checks

```bash
# Quick status
make status

# Check for errors
make logs-error
```

### Weekly Maintenance

```bash
# View statistics
make logs-stats

# Cleanup old logs
docker exec claude-flow-alpha bash -c "source /workspace/lib/logger.sh && log_cleanup 7"

# Check disk usage
docker exec claude-flow-alpha df -h /workspace
```

### Monthly Tasks

```bash
# Backup
make backup

# Review log patterns
make logs-viewer
# Analyze common warnings/errors

# Update container if needed
git pull origin main
make clean && make build && make start
```

## 🔄 Rollback Procedure

If deployment causes issues:

### Option 1: Quick Rollback

```bash
# Stop new version
make stop

# Restore from backup
make restore BACKUP=backups/claude-flow-backup-YYYYMMDD-HHMMSS.tar.gz

# Start
make start
```

### Option 2: Git Rollback

```bash
# Find commit before changes
git log --oneline

# Checkout previous version
git checkout <previous-commit>

# Rebuild
make clean
make build
make start
```

### Option 3: Remove Logging Changes Only

```bash
# Revert logging env vars
vim .env  # Remove LOG_* variables

# Keep using new container
# Logging will use defaults
```

## ✅ Success Criteria

Deployment is successful if:

- [ ] Container starts without errors
- [ ] `make logs-stats` shows statistics
- [ ] `make logs-app` displays real-time logs
- [ ] `make logs-error` shows no errors
- [ ] `claude mcp list` shows connected
- [ ] Claude Code can invoke MCP tools
- [ ] Log file exists and is being written to
- [ ] Resource usage is normal (check with `make stats`)

## 📝 Post-Deployment Tasks

After successful deployment:

1. **Update Documentation**
   - Document any custom configurations
   - Update team wiki/docs
   - Share new log viewing commands

2. **Train Team**
   - Show `make logs-viewer`
   - Explain log levels
   - Demonstrate debugging

3. **Set Up Monitoring**
   - Configure alerts
   - Set up log rotation schedule
   - Plan log retention policy

4. **Performance Baseline**
   ```bash
   make stats > baseline-stats.txt
   make logs-stats >> baseline-stats.txt
   ```

## 🎉 You're Done!

Your claude-flow-docker deployment now includes:

- ✅ Advanced logging system
- ✅ Real-time log viewing
- ✅ Error tracking
- ✅ MCP event monitoring
- ✅ Automatic log rotation
- ✅ Interactive log viewer
- ✅ Clean repository

## 📞 Need Help?

- 📖 Check [LOGGING.md](LOGGING.md) for logging details
- 🧹 Check [CLEANUP_GUIDE.md](CLEANUP_GUIDE.md) for cleanup info
- 🔧 Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for common issues
- 📊 Check [CHANGES_SUMMARY.md](CHANGES_SUMMARY.md) for overview
- 🐛 [Open GitHub Issue](https://github.com/1nk1/claude-flow-docker/issues)

---

**Version:** 2.0.0
**Last Updated:** November 17, 2025
**Status:** Production Ready
