# Claude Configuration for Docker

## Files

### settings.json (Recommended)
Full-featured configuration with all MCP servers and descriptions.

**Features:**
- 4 MCP servers (docker, hive, memory, github)
- 4 hooks (pre-edit, post-edit, session-start, session-end)
- Environment variables
- Debug logging
- Descriptions for each server

**Use this for:** Production projects, complex workflows

### settings-minimal.json (Simplified)
Minimal configuration with just one MCP server.

**Features:**
- 1 MCP server (main claude-flow-docker)
- 4 hooks (all essential workflows)
- Minimal environment variables

**Use this for:** Quick setup, simple projects, testing

## Installation

### Option 1: Full Configuration (Recommended)

```bash
# Copy to your project
cp settings.json ~/.claude/settings.json

# Or to project-specific config
cp settings.json /path/to/your/project/.claude/settings.json
```

### Option 2: Minimal Configuration

```bash
# Copy minimal config
cp settings-minimal.json ~/.claude/settings.json
```

## Usage

### Start Container First

```bash
cd ~/repos/claude-flow-docker
make start

# Verify container is running
docker ps | grep claude-flow-alpha
```

### Use with Claude Code

```bash
cd /path/to/your/project

# Copy config if not done
cp ~/repos/claude-flow-docker/config/.claude/settings.json ./.claude/

# Start Claude Code
claude
```

### Test MCP Connection

```bash
# Test main MCP server
echo '{"jsonrpc":"2.0","id":1,"method":"initialize"}' | \
  docker exec -i claude-flow-alpha npx claude-flow mcp

# Should return: {"jsonrpc":"2.0","id":1,"result":{"capabilities":{...}}}
```

## Available MCP Servers (Full Config)

### 1. claude-flow-docker (Main)
- **Command:** `npx claude-flow mcp`
- **Purpose:** Main orchestration and coordination
- **Use for:** All general AI tasks

### 2. claude-flow-hive
- **Command:** `npx claude-flow hive-mind mcp`
- **Purpose:** Hive-mind multi-agent coordination
- **Use for:** Complex tasks requiring multiple agents

### 3. claude-flow-memory
- **Command:** `npx claude-flow memory mcp`
- **Purpose:** Memory and knowledge base
- **Use for:** Storing and retrieving project knowledge

### 4. claude-flow-github
- **Command:** `npx claude-flow github mcp`
- **Purpose:** GitHub integration
- **Use for:** Repository operations

## Hooks System

All hooks run automatically:

### preEditHook
- Runs before file editing
- Validates file
- Auto-assigns appropriate agents
- `alwaysRun: false` (only when needed)

### postEditHook
- Runs after file editing
- Auto-formats code
- Learns from edits
- `alwaysRun: true` (always runs)

### sessionStartHook
- Runs when session starts
- Restores previous context
- Loads memory
- `alwaysRun: true` (always runs)

### sessionEndHook
- Runs when session ends
- Generates summary
- Persists state
- Saves memory
- `alwaysRun: true` (always runs)

## Troubleshooting

### MCP Server Not Responding

```bash
# Check container is running
docker ps | grep claude-flow-alpha

# Restart container
cd ~/repos/claude-flow-docker
make restart

# Test MCP
docker exec -i claude-flow-alpha npx claude-flow --version
```

### Hooks Not Working

```bash
# Check hook configuration
cat ~/.claude/settings.json | jq '.hooks'

# Test hook manually
docker exec claude-flow-alpha npx claude-flow hooks pre-edit --file test.js
```

### Environment Variables Not Set

Edit settings.json and add:

```json
"env": {
  "CLAUDE_FLOW_HOME": "/workspace",
  "CLAUDE_FLOW_PROJECT": "/workspace/project",
  "NODE_ENV": "development"
}
```

## Differences Between Configs

| Feature | settings.json | settings-minimal.json |
|---------|---------------|----------------------|
| MCP Servers | 4 (docker, hive, memory, github) | 1 (docker only) |
| Hooks | 4 (all) | 4 (all) |
| Env Variables | Comprehensive | Minimal |
| Descriptions | Yes | No |
| Debug Logging | Yes | No |
| Size | ~135 lines | ~35 lines |
| Complexity | Advanced | Simple |

## Which Config to Choose?

**Use settings.json if:**
- Working on complex projects
- Need multi-agent coordination
- Want GitHub integration
- Need memory persistence
- Want debug logging

**Use settings-minimal.json if:**
- Just getting started
- Simple projects
- Quick testing
- Don't need advanced features
- Want minimal setup

## Examples

### Using with flutter_keycheck

```bash
cd ~/projects/flutter_keycheck

# Copy config
mkdir -p .claude
cp ~/repos/claude-flow-docker/config/.claude/settings.json ./.claude/

# Start Claude Code
claude

# Claude will automatically use Docker MCP servers!
```

### Custom Project Configuration

Create `.claude/settings.json` in your project:

```json
{
  "mcpServers": {
    "claude-flow-docker": {
      "command": "docker",
      "args": ["exec", "-i", "claude-flow-alpha", "npx", "claude-flow", "mcp"],
      "env": {
        "CLAUDE_FLOW_PROJECT": "/workspace/my-custom-project"
      }
    }
  },
  "hooks": {
    "postEditHook": {
      "command": "docker",
      "args": ["exec", "claude-flow-alpha", "npx", "claude-flow", "hooks", "post-edit", "--file", "${file}"],
      "alwaysRun": true
    }
  }
}
```

## Support

- **Documentation:** [README.md](../../README.md)
- **Issues:** https://github.com/1nk1/claude-flow-docker/issues
- **Upstream:** https://github.com/ruvnet/claude-flow

---

**All MCP servers run inside Docker container for isolation and consistency!**
