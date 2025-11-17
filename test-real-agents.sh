#!/bin/bash
# Real agent workflow test - NOT a demo
# This creates actual claude-flow agents and shows visualization

set -e

echo "🚀 Testing REAL Agent Workflows (not demo)"
echo ""
echo "This will:"
echo "  1. Create a real memory entry"
echo "  2. Query the memory system"
echo "  3. Show agent activity logs"
echo ""
echo "Press Ctrl+C to stop"
echo ""

# Terminal 1: Follow agent logs in background
echo "📊 Starting agent log monitor..."
docker exec claude-flow-alpha bash -c 'tail -f /workspace/logs/agents.log' &
LOG_PID=$!

sleep 2

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "TEST 1: Memory Operations (shows internal agents)"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# Store a memory (triggers internal agents)
docker exec claude-flow-alpha bash -c "
echo 'Testing memory storage with real agents...'
claude-flow memory store 'test-namespace' 'First real test' '{\"type\":\"test\",\"timestamp\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",\"message\":\"Testing agent visualization with real workflow\"}'
"

sleep 2

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "TEST 2: Query Memory (shows retrieval agents)"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# Query memory (triggers retrieval agents)
docker exec claude-flow-alpha bash -c "
echo 'Querying memory with agents...'
claude-flow memory query 'test workflow'
"

sleep 2

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "TEST 3: Hive-Mind Initialization (spawns coordinator agents)"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# Initialize hive-mind (spawns multiple agents)
docker exec claude-flow-alpha bash -c "
echo 'Initializing hive-mind system...'
claude-flow hive-mind init || true
"

sleep 2

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "TEST 4: View Active Agents Status"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# Show active agents
docker exec claude-flow-alpha bash -c "
source /workspace/lib/agent-logger.sh
show_active_agents
"

sleep 2

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "TEST 5: Agent Logs (last 20 entries)"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# Show recent agent logs
docker exec claude-flow-alpha tail -n 20 /workspace/logs/agents.log

# Kill background log monitor
kill $LOG_PID 2>/dev/null || true

echo ""
echo "✅ Real agent workflow test complete!"
echo ""
echo "To monitor agents in real-time:"
echo "  make agents-logs      # Follow agent activity"
echo "  make agents           # Show active agents"
echo "  lazydocker            # Visual monitoring"
echo ""
