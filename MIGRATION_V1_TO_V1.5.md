# 🚀 Migration Guide: v1.0 → v1.5

This guide helps you migrate from Claude-Flow Docker v1.0 to v1.5 with Ollama and GPU support.

---

## 📊 Before You Start

### What's Changing

| Component | v1.0 | v1.5 | Impact |
|-----------|------|------|--------|
| Containers | 1 | 3 | New: redis, ollama |
| RAM Usage | 4GB | 6-8GB | +2-4GB |
| Disk Space | 2GB | 17GB | +15GB (models) |
| Compose File | docker-compose.yml | docker-compose.v1.5*.yml | New file |
| Configuration | Same | + Smart routing | New env vars |

### Prerequisites

- ✅ v1.0 is running successfully
- ✅ Docker 20.10+
- ✅ 8GB+ RAM available
- ✅ 20GB+ disk space available
- ✅ (Optional) GPU with drivers installed

### Backup First!

```bash
# 1. Backup your data
docker exec claude-flow-alpha tar czf /workspace/backups/pre-v1.5-migration-$(date +%Y%m%d).tar.gz \
  /workspace/.hive-mind \
  /workspace/.swarm \
  /workspace/project

# 2. Verify backup exists
ls -lh backups/

# 3. Export current state
docker inspect claude-flow-alpha > v1.0-state.json
```

---

## 🔄 Migration Options

### Option A: In-Place Migration (Recommended)

Migrate existing v1.0 installation to v1.5.

**Advantages:**
- ✅ Keep all data
- ✅ Minimal downtime
- ✅ Easy rollback

**Time:** ~30 minutes

### Option B: Fresh Installation

Start fresh with v1.5.

**Advantages:**
- ✅ Clean state
- ✅ No conflicts
- ✅ Latest everything

**Time:** ~45 minutes

### Option C: Side-by-Side

Run v1.0 and v1.5 together.

**Advantages:**
- ✅ Test before switch
- ✅ No downtime
- ✅ Compare performance

**Time:** ~1 hour

---

## 📋 Option A: In-Place Migration

### Step 1: Prepare

```bash
# Navigate to repository
cd claude-flow-docker

# Pull latest changes
git fetch origin
git checkout feature/IMP-001-claude-flow-docker-v2-ollama-gpu
git pull

# Verify new files exist
ls -l docker-compose.v1.5*.yml
ls -l detect-hardware.sh init-ollama.sh verify-v1.5.sh
```

### Step 2: Stop v1.0

```bash
# Stop current containers (keeps volumes)
make stop

# Verify stopped
docker ps | grep claude-flow
# Should show nothing

# Verify volumes exist
docker volume ls | grep claude-flow-docker
# Should show volumes
```

### Step 3: Detect Hardware

```bash
# Make scripts executable
chmod +x detect-hardware.sh init-ollama.sh verify-v1.5.sh

# Detect your hardware
./detect-hardware.sh

# Review output and save to environment
source .detected-hardware.env

# Verify
echo $COMPOSE_FILE
# Should show: docker-compose.v1.5.yml or docker-compose.v1.5-amd.yml
```

### Step 4: Update Configuration

```bash
# Backup old config
cp config/.claude/settings.json config/.claude/settings.json.v1.0.bak

# V1.5 config is already updated in the repo
# Verify it exists
cat config/.claude/settings.json | jq .

# If you have custom MCP configs, merge them manually
```

### Step 5: Start v1.5

```bash
# Start new stack
docker compose -f $COMPOSE_FILE up -d

# Wait for healthy
sleep 30

# Check all containers
docker ps
# Should show: claude-flow-alpha, claude-ollama, claude-redis
```

### Step 6: Verify Data Migrated

```bash
# Check your data still exists
docker exec claude-flow-alpha ls -la /workspace/.hive-mind
docker exec claude-flow-alpha ls -la /workspace/.swarm
docker exec claude-flow-alpha ls -la /workspace/project

# Test claude-flow still works
docker exec claude-flow-alpha npx claude-flow --version
docker exec claude-flow-alpha npx claude-flow memory stats
```

### Step 7: Initialize Ollama

```bash
# Download Ollama models (~10-30 minutes)
./init-ollama.sh

# Answer prompts:
# - For RX 7900 XT: Answer 'y' to 34b and 70b models
# - For other GPUs: Skip large models

# Verify models installed
docker exec claude-ollama ollama list
```

### Step 8: Verify Everything

```bash
# Run verification
./verify-v1.5.sh

# Should show:
# ✅ All checks passed
# ✅ Claude-Flow v1.5 is ready to use!
```

### Step 9: Test Integration

```bash
# Update your project config
cd ~/your-project
cp ~/claude-flow-docker/config/.claude/settings.json ./.claude/

# Start Claude Code
claude

# Test simple query (should use Ollama)
# You: "What is quicksort?"

# Test complex query (should use Claude API)
# You: "Design a microservices architecture"
```

### Step 10: Monitor Performance

```bash
# Check routing stats after a few queries
docker exec claude-flow-alpha node -e "
const SmartRouter = require('./lib/smart-router');
const router = new SmartRouter();
router.getStats().then(stats => {
  console.log('Router Statistics:');
  console.log('  Total queries:', stats.total);
  console.log('  Ollama (local):', stats.ollama);
  console.log('  Claude API:', stats.api);
  console.log('  Cached:', stats.cached);
  console.log('  Cache hit rate:', stats.cacheHitRate);
});
"
```

**✅ Migration Complete!** You're now running v1.5 with Ollama.

---

## 🆕 Option B: Fresh Installation

### Step 1: Remove Old Installation

```bash
# Stop and remove old containers
cd claude-flow-docker
make clean

# Optional: Remove old images
docker rmi $(docker images | grep claude-flow | awk '{print $3}')

# Keep data volumes or remove?
# KEEP DATA: Skip this step
# FRESH START: 
docker volume rm $(docker volume ls | grep claude-flow-docker | awk '{print $2}')
```

### Step 2: Pull Latest Code

```bash
# Pull latest v1.5
git checkout feature/IMP-001-claude-flow-docker-v2-ollama-gpu
git pull

# Make scripts executable
chmod +x *.sh
```

### Step 3: Follow Quick Start

```bash
# Detect hardware
./detect-hardware.sh
source .detected-hardware.env

# Start services
docker compose -f $COMPOSE_FILE up -d

# Initialize Ollama
./init-ollama.sh

# Verify
./verify-v1.5.sh

# Configure project
cd ~/your-project
cp ~/claude-flow-docker/config/.claude/settings.json ./.claude/
claude
```

**✅ Fresh Installation Complete!**

---

## 🔄 Option C: Side-by-Side

Run both versions simultaneously for testing.

### Step 1: Clone to New Directory

```bash
# Keep existing v1.0
cd ~
mv claude-flow-docker claude-flow-docker-v1.0

# Clone v1.5
git clone -b feature/IMP-001-claude-flow-docker-v2-ollama-gpu https://github.com/1nk1/claude-flow-docker.git claude-flow-docker-v1.5
cd claude-flow-docker-v1.5
```

### Step 2: Modify Ports (Avoid Conflicts)

```bash
# Edit docker-compose file to use different ports
sed -i 's/3000:3000/3001:3000/' docker-compose.v1.5*.yml
sed -i 's/11434:11434/11435:11434/' docker-compose.v1.5*.yml
sed -i 's/6379:6379/6380:6379/' docker-compose.v1.5*.yml

# Update container names
sed -i 's/claude-flow-alpha/claude-flow-v1.5/' docker-compose.v1.5*.yml
sed -i 's/claude-ollama/claude-ollama-v1.5/' docker-compose.v1.5*.yml
sed -i 's/claude-redis/claude-redis-v1.5/' docker-compose.v1.5*.yml
```

### Step 3: Start v1.5

```bash
# Detect hardware
./detect-hardware.sh
source .detected-hardware.env

# Start v1.5 (on different ports)
docker compose -f $COMPOSE_FILE up -d

# Initialize Ollama
./init-ollama.sh

# Verify
./verify-v1.5.sh
```

### Step 4: Compare Performance

```bash
# v1.0 is on port 3000
# v1.5 is on port 3001

# Test both and compare:
# - Response times
# - Quality
# - Resource usage

# Monitor resources
docker stats
```

### Step 5: Choose Winner

```bash
# Keep v1.5, remove v1.0
cd ~/claude-flow-docker-v1.0
make clean
cd ~/claude-flow-docker-v1.5
# Change ports back to standard

# OR keep v1.0, remove v1.5
cd ~/claude-flow-docker-v1.5
docker compose down
```

---

## 🔧 Post-Migration Tasks

### Update MCP Configuration

If you have multiple projects:

```bash
# Update all projects
for project in ~/projects/*; do
  if [ -d "$project/.claude" ]; then
    echo "Updating $project"
    cp ~/claude-flow-docker/config/.claude/settings.json "$project/.claude/"
  fi
done
```

### Configure Smart Routing

```bash
# Edit .env for your preferences
cd ~/claude-flow-docker

cat > .env << EOF
# Smart Routing Configuration
USE_OLLAMA_FOR_SIMPLE=true
OLLAMA_TIMEOUT=30000
CACHE_TTL=3600

# GPU Configuration (auto-detected)
GPU_VENDOR=$(cat .detected-hardware.env | grep GPU= | cut -d= -f2)
VRAM_SIZE=$(cat .detected-hardware.env | grep GPU_NAME | grep -o '[0-9]*GB' || echo "unknown")

# Redis Configuration
REDIS_MAXMEMORY=512mb
EOF

# Restart to apply
docker compose -f $COMPOSE_FILE restart
```

### Set Up Monitoring

```bash
# Add cron job for stats
crontab -e

# Add this line:
0 * * * * cd ~/claude-flow-docker && docker exec claude-flow-alpha node -e "const SmartRouter = require('./lib/smart-router'); const router = new SmartRouter(); router.getStats().then(console.log);" >> ~/claude-flow-stats.log
```

---

## 📊 Verification Checklist

After migration, verify:

- [ ] All containers running (`docker ps`)
- [ ] Health checks passing (`docker ps` - healthy status)
- [ ] Redis responding (`docker exec claude-redis redis-cli ping`)
- [ ] Ollama responding (`docker exec claude-ollama ollama list`)
- [ ] Models installed (`docker exec claude-ollama ollama list | grep -c codellama`)
- [ ] GPU detected (check `./detect-hardware.sh` output)
- [ ] Claude-Flow working (`docker exec claude-flow-alpha npx claude-flow --version`)
- [ ] Old data accessible (`docker exec claude-flow-alpha ls /workspace/.hive-mind`)
- [ ] MCP config updated (`cat ~/.claude/settings.json`)
- [ ] Claude Code connects (`claude --version`)
- [ ] Smart routing works (test simple query)
- [ ] Cache working (repeat query, should be instant)

---

## 🚨 Rollback Instructions

If something goes wrong:

### Quick Rollback

```bash
# Stop v1.5
docker compose -f $COMPOSE_FILE down

# Start v1.0
cd ~/claude-flow-docker
docker compose -f docker-compose.yml up -d

# Restore config
cp config/.claude/settings.json.v1.0.bak config/.claude/settings.json
cp config/.claude/settings.json ~/.claude/

# Verify
docker ps
make status
```

### Full Rollback

```bash
# Remove v1.5 completely
docker compose -f $COMPOSE_FILE down -v

# Checkout v1.0
git checkout main

# Rebuild
make clean
make build
make start

# Restore backup
docker exec claude-flow-alpha tar xzf /workspace/backups/pre-v1.5-migration-*.tar.gz -C /
```

---

## 🆘 Troubleshooting

### "Ollama container won't start"

```bash
# Check GPU access
./detect-hardware.sh

# Try CPU-only mode
docker compose -f docker-compose.v1.5.yml up -d
```

### "Models download is too slow"

```bash
# Download one at a time
docker exec claude-ollama ollama pull codellama:7b

# Or use smaller models
docker exec claude-ollama ollama pull mistral:7b
```

### "Smart routing not working"

```bash
# Check environment variables
docker exec claude-flow-alpha env | grep OLLAMA

# Test manually
docker exec claude-ollama ollama run codellama "test"
```

### "Redis connection errors"

```bash
# Check Redis is running
docker ps | grep redis

# Test connection
docker exec claude-redis redis-cli ping

# Restart if needed
docker restart claude-redis
```

---

## 💡 Tips & Best Practices

### Optimal Settings for Your Hardware

**RX 7900 XT (24GB VRAM):**
```bash
# Download large models
docker exec claude-ollama ollama pull llama2:70b
docker exec claude-ollama ollama pull codellama:34b

# Set high cache
echo "CACHE_TTL=7200" >> .env
```

**MacBook M3 Max:**
```bash
# Use recommended models
# codellama:13b works great
docker exec claude-ollama ollama pull codellama:13b
```

**CPU Only:**
```bash
# Use smaller models
docker exec claude-ollama ollama pull mistral:7b

# Increase timeout
echo "OLLAMA_TIMEOUT=60000" >> .env
```

### Performance Tuning

```bash
# For more aggressive local inference:
echo "USE_OLLAMA_FOR_SIMPLE=true" >> .env

# For better quality (more API usage):
echo "USE_OLLAMA_FOR_SIMPLE=false" >> .env

# For maximum caching:
echo "CACHE_TTL=86400" >> .env  # 24 hours
```

---

## 📈 What's Next?

After successful migration:

1. **Monitor Performance** - Track routing stats daily
2. **Adjust Settings** - Tune based on your usage
3. **Explore Features** - Try hive-mind with Ollama
4. **Share Feedback** - Report issues or suggestions
5. **Stay Updated** - Watch for v1.6 improvements

---

## 📞 Need Help?

- **Issues**: https://github.com/1nk1/claude-flow-docker/issues
- **Discussions**: https://github.com/1nk1/claude-flow-docker/discussions
- **Documentation**: Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md)

---

**Happy migrating! 🚀**

Version: 1.5.0  
Last Updated: 2025-01-04
