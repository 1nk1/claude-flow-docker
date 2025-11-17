# Claude Code Update Guide for Docker Container

## Current Status
- **Container Name**: claude-flow-alpha
- **Current Claude Code Version**: 2.0.21
- **Latest Available Version**: 2.0.27
- **Installation Method**: npm global package (@anthropic-ai/claude-code)

## Quick Update Commands

### 1. Check Current Version
```bash
docker exec claude-flow-alpha claude --version
```

### 2. Check Available Updates
```bash
docker exec claude-flow-alpha npm view @anthropic-ai/claude-code version
```

### 3. Update to Latest Version (Automated)
```bash
# Use the provided script
./update-claude-code.sh
```

### 4. Rollback if Needed
```bash
# Rollback to previous version (2.0.21)
./rollback-claude-code.sh 2.0.21
```

## Manual Update Methods

### Option 1: Update Inside Running Container
This is the simplest and fastest method for updating Claude Code.

```bash
# Step 1: Enter the container
docker exec -it claude-flow-alpha bash

# Step 2: Check current version
claude --version

# Step 3: Update Claude Code to latest
npm install -g @anthropic-ai/claude-code@latest

# OR update to specific version
npm install -g @anthropic-ai/claude-code@2.0.27

# Step 4: Verify new version
claude --version

# Step 5: Test claude-flow integration
claude-flow mcp start --test

# Step 6: Exit container
exit
```

### Option 2: Update Without Entering Container
Run commands directly from host:

```bash
# Update to latest
docker exec claude-flow-alpha npm install -g @anthropic-ai/claude-code@latest

# Verify update
docker exec claude-flow-alpha claude --version

# Test MCP integration
docker exec -i claude-flow-alpha claude-flow mcp start --test
```

### Option 3: Rebuild Docker Image (Permanent Update)
If you want the update to persist across container recreations:

1. **Find the Dockerfile** (if exists):
```bash
# Look for Dockerfile
find . -name "Dockerfile*" | grep claude-flow
```

2. **Update Dockerfile**:
```dockerfile
FROM node:18-alpine

# Install specific Claude Code version
RUN npm install -g @anthropic-ai/claude-code@2.0.27

# OR install latest version
RUN npm install -g @anthropic-ai/claude-code@latest

# ... rest of your Dockerfile configuration
```

3. **Rebuild and restart container**:
```bash
# Stop current container
docker stop claude-flow-alpha

# Remove old container
docker rm claude-flow-alpha

# Rebuild image
docker build -t claude-flow-claude-flow .

# Run new container with same configuration
docker run -d \
  --name claude-flow-alpha \
  -p 8811:8811 \
  -e CLAUDE_FLOW_HOME=/workspace \
  -e CLAUDE_FLOW_PROJECT=/workspace/project \
  -e CLAUDE_FLOW_STORAGE=/workspace/.swarm \
  claude-flow-claude-flow
```

### Option 4: Using Docker Compose (if applicable)
If using docker-compose:

```bash
# Update docker-compose.yml to specify version
# Then rebuild:
docker-compose down
docker-compose build --no-cache claude-flow-alpha
docker-compose up -d
```

## Verification Steps

After updating, verify everything works correctly:

### 1. Version Check
```bash
docker exec claude-flow-alpha claude --version
# Expected: 2.0.27 (Claude Code) or later
```

### 2. NPM Package Check
```bash
docker exec claude-flow-alpha npm list -g @anthropic-ai/claude-code
# Should show the new version installed globally
```

### 3. MCP Server Test
```bash
# Test MCP server starts correctly
docker exec -i claude-flow-alpha claude-flow mcp start --test

# Or test actual MCP connection from your project
# The MCP configuration should continue working
```

### 4. Claude Flow Commands
```bash
# Test basic claude-flow commands
docker exec claude-flow-alpha claude-flow --version
docker exec claude-flow-alpha claude-flow status
```

### 5. Full Integration Test
Test the MCP connection from your actual project:
- Ensure the MCP server in `.mcp.json` still connects
- Try running a command through the MCP interface
- Verify claude-flow commands work as expected

## Troubleshooting

### Issue: Update fails with permission errors
```bash
# Try with sudo inside container
docker exec -it claude-flow-alpha bash
sudo npm install -g @anthropic-ai/claude-code@latest
```

### Issue: MCP connection fails after update
1. Check if claude-flow is compatible:
```bash
docker exec claude-flow-alpha claude-flow --version
```

2. Restart the container:
```bash
docker restart claude-flow-alpha
```

3. Check logs:
```bash
docker logs claude-flow-alpha --tail 50
```

### Issue: Command not found after update
```bash
# Refresh npm global binaries
docker exec claude-flow-alpha npm rebuild -g
```

### Issue: Version mismatch between claude-flow and claude-code
```bash
# Check both versions
docker exec claude-flow-alpha claude --version
docker exec claude-flow-alpha claude-flow --version

# May need to update claude-flow as well
docker exec claude-flow-alpha npm install -g claude-flow@latest
```

## Rollback Procedure

If the update causes issues, you can rollback to the previous version:

### Quick Rollback
```bash
# Use the rollback script
./rollback-claude-code.sh 2.0.21
```

### Manual Rollback
```bash
# Rollback to specific version
docker exec claude-flow-alpha npm install -g @anthropic-ai/claude-code@2.0.21

# Verify rollback
docker exec claude-flow-alpha claude --version

# Test functionality
docker exec -i claude-flow-alpha claude-flow mcp start --test
```

## Best Practices

1. **Always backup before updating**: Save current version info
   ```bash
   docker exec claude-flow-alpha npm list -g > claude-versions-backup.txt
   ```

2. **Test in staging first**: If possible, test updates in a non-production container

3. **Update during low-activity periods**: Minimize disruption

4. **Document version changes**: Keep track of what versions work with your setup

5. **Monitor after update**: Check logs and functionality for a few hours after update

## Version Compatibility Matrix

| Claude Code Version | claude-flow Version | Status |
|-------------------|-------------------|---------|
| 2.0.21           | 2.7.0-alpha.10    | ✅ Working |
| 2.0.27           | 2.7.0-alpha.10    | 🔄 Testing |
| Latest           | Latest            | ⚠️ Test Required |

## Automated Update Script Features

The provided `update-claude-code.sh` script includes:
- ✅ Automatic version checking
- ✅ Backup creation before update
- ✅ MCP connection testing
- ✅ Color-coded output for clarity
- ✅ Error handling and validation
- ✅ Update summary report

## Security Considerations

1. **Version Pinning**: Consider pinning to specific versions in production
2. **Testing**: Always test updates in non-production first
3. **Rollback Plan**: Keep the rollback script ready
4. **Monitoring**: Watch for deprecation warnings or breaking changes

## Additional Resources

- [Claude Code Release Notes](https://github.com/anthropics/claude-code/releases)
- [NPM Package Page](https://www.npmjs.com/package/@anthropic-ai/claude-code)
- [claude-flow Documentation](https://docs.claude-flow.dev)

## Support

If you encounter issues:
1. Check the container logs: `docker logs claude-flow-alpha`
2. Verify MCP configuration in `.mcp.json`
3. Test individual components separately
4. Rollback if necessary and investigate

---

**Last Updated**: 2025-10-25
**Current Production Version**: 2.0.21
**Recommended Update**: 2.0.27