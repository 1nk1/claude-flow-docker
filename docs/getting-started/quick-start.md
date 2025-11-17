# 🚀 START HERE - Claude-Flow Docker v2.0

## ⚡ 30-Second Overview

This repository just got a **major upgrade** with:

✅ **Advanced Logging System** - See exactly what's happening
✅ **Clean Repository** - Removed 14+ redundant files
✅ **Better Documentation** - Clear guides for everything
✅ **Production Ready** - Auto-rotation, monitoring, debugging tools

## 🎯 What to Do Now

### If You're New Here

```bash
# 1. Setup
make setup

# 2. Configure
vim .env  # Set PROJECT_PATH and ANTHROPIC_API_KEY

# 3. Start
make build
make start

# 4. Watch the magic
make logs-app
```

**Time to productivity:** 5 minutes

### If You're Upgrading

```bash
# 1. Backup first
make backup

# 2. Update config
cat >> .env << 'EOF'
LOG_LEVEL=INFO
LOG_TO_FILE=true
LOG_FILE=/workspace/logs/claude-flow.log
EOF

# 3. Rebuild
make clean
make build
make start

# 4. Verify
make logs-stats
```

**Time to upgrade:** 10 minutes

## 📚 Key Documents

| Document | When to Read | Time |
|----------|-------------|------|
| [README.md](README.md) | Getting started, main docs | 5 min |
| [DEPLOYMENT.md](DEPLOYMENT.md) | Deploying/upgrading | 10 min |
| [LOGGING.md](LOGGING.md) | Using the logging system | 15 min |
| [CHANGES_SUMMARY.md](CHANGES_SUMMARY.md) | What changed in v2.0 | 5 min |
| [CLEANUP_GUIDE.md](CLEANUP_GUIDE.md) | Repository cleanup details | 5 min |

## 🎮 Essential Commands

### View Logs

```bash
make logs-app          # Follow application logs (real-time)
make logs-viewer       # Interactive log viewer (recommended!)
make logs-stats        # Statistics
make logs-error        # Find errors
make logs-mcp          # View MCP events
```

### Container Management

```bash
make start             # Start container
make stop              # Stop container
make restart           # Restart
make status            # Check status
make logs              # View container logs
```

### Debugging

```bash
make shell             # Interactive shell
make logs-error        # Find errors
LOG_LEVEL=DEBUG make start  # Verbose logging
```

## 🎁 New Features

### 1. Interactive Log Viewer

```bash
make logs-viewer
```

Features:
- Real-time log following
- Error/warning search
- MCP event filtering
- Pattern search
- Export logs
- 12 viewing modes

### 2. Advanced Logging

```bash
# View real-time
make logs-app

# Search for issues
make logs-error
make logs-warn

# Get statistics
make logs-stats
```

### 3. Better Visibility

Every container startup now shows:
- System information
- Node.js & npm versions
- Claude Code status
- Claude-Flow installation
- MCP configuration
- Database status
- Usage instructions

## 🔧 Quick Troubleshooting

### Container won't start?

```bash
docker logs claude-flow-alpha
make check-env
```

### Logs not working?

```bash
docker exec claude-flow-alpha ls -la /workspace/logs/
make restart
```

### MCP connection issues?

```bash
./connect-mcp.sh ~/your-project
claude mcp list
```

### Need to rollback?

```bash
git checkout HEAD~1
make clean && make build && make start
```

## 📊 What Changed?

### Added (7 files)

- `lib/logger.sh` - Comprehensive logging library (420 lines)
- `view-logs.sh` - Interactive log viewer (257 lines)
- `LOGGING.md` - Complete logging documentation (499 lines)
- `CLEANUP_GUIDE.md` - Cleanup documentation (233 lines)
- `CHANGES_SUMMARY.md` - Change overview (430 lines)
- `DEPLOYMENT.md` - Deployment guide (569 lines)
- `START_HERE.md` - This file!

**Total new documentation/code:** ~2,800 lines

### Updated (6 files)

- `docker-entrypoint.sh` - Complete rewrite with logging (370 lines)
- `Dockerfile` - Added logging support
- `docker-compose.yml` - Logging environment variables
- `.env.example` - Logging configuration
- `README.md` - Updated with logging info
- `Makefile` - 8 new logging commands

### Removed (14 files)

Old scripts:
- cf-exec.sh, cf-logs.sh, cf-shell.sh, cf-start.sh, cf-stop.sh
- apply-complete-fix.sh, verify-all.sh, fix-dockerfile.sh, fix-node22.sh

Redundant docs:
- BADGE_FIX_GUIDE.md, FINAL_DEPLOYMENT_GUIDE.md, GITHUB_SETUP.md
- PACKAGE_README.md, PROJECT_SUMMARY.md

## 💡 Tips

### Daily Use

```bash
# Quick status check
make status

# Follow logs while working
make logs-app
```

### Development

```bash
# Enable debug logging
echo "LOG_LEVEL=DEBUG" >> .env
make restart

# Watch everything
make logs-viewer
```

### Production

```bash
# Less verbose
echo "LOG_LEVEL=WARN" >> .env
make restart

# Monitor resources
make watch
```

## 🎯 Next Steps

1. **Read the deployment guide** if upgrading
   ```bash
   cat DEPLOYMENT.md
   ```

2. **Try the log viewer**
   ```bash
   make logs-viewer
   ```

3. **Check the changes summary**
   ```bash
   cat CHANGES_SUMMARY.md
   ```

4. **Test MCP connection**
   ```bash
   claude mcp list
   ```

## 🆘 Need Help?

1. Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
2. View logs: `make logs-viewer`
3. Check status: `make status`
4. [Open an issue](https://github.com/1nk1/claude-flow-docker/issues)

## 🎉 Ready to Go!

```bash
# Quick start
make build && make start

# Watch it work
make logs-app

# Have fun! 🚀
```

---

**Version:** 2.0.0
**Updated:** November 17, 2025
**Status:** Production Ready ✅
