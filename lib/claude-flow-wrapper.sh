#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════
# Claude-Flow Wrapper with Agent Visualization
# Intercepts claude-flow commands and provides real-time agent logging
# ═══════════════════════════════════════════════════════════════════════════

# Load agent logger
if [ -f /workspace/lib/agent-logger.sh ]; then
    source /workspace/lib/agent-logger.sh
fi

# Original claude-flow command (use global installation)
# Find the real claude-flow binary (not this wrapper)
CLAUDE_FLOW_REAL=$(find /usr/local/lib/node_modules/.bin -name "claude-flow" 2>/dev/null | head -1)
if [ -z "$CLAUDE_FLOW_REAL" ]; then
    # Fallback to npx if global not found
    CLAUDE_FLOW_BIN="/usr/local/bin/npx"
    CLAUDE_FLOW_ARGS="claude-flow@alpha"
else
    CLAUDE_FLOW_BIN="$CLAUDE_FLOW_REAL"
    CLAUDE_FLOW_ARGS=""
fi

# ═══════════════════════════════════════════════════════════════════════════
# Agent Detection and Logging
# ═══════════════════════════════════════════════════════════════════════════

parse_agent_output() {
    local agent_id=0
    local current_agent=""
    local current_spec=""

    while IFS= read -r line; do
        # Detect agent creation
        if [[ "$line" =~ "Creating agent"|"Spawning agent"|"Agent created"|"Starting agent" ]]; then
            agent_id=$((agent_id + 1))

            # Extract agent name
            if [[ "$line" =~ \"([^\"]+)\" ]]; then
                current_agent="${BASH_REMATCH[1]}"
            else
                current_agent="Agent-${agent_id}"
            fi

            # Detect specialization
            if [[ "$line" =~ "coordinator" ]]; then
                current_spec="coordinator"
            elif [[ "$line" =~ "researcher" ]]; then
                current_spec="researcher"
            elif [[ "$line" =~ "coder" ]]; then
                current_spec="coder"
            elif [[ "$line" =~ "reviewer" ]]; then
                current_spec="reviewer"
            elif [[ "$line" =~ "tester" ]]; then
                current_spec="tester"
            elif [[ "$line" =~ "optimizer" ]]; then
                current_spec="optimizer"
            elif [[ "$line" =~ "designer" ]]; then
                current_spec="designer"
            elif [[ "$line" =~ "planner" ]]; then
                current_spec="planner"
            else
                current_spec="default"
            fi

            log_agent_start "$agent_id" "$current_agent" "$current_spec"
        fi

        # Detect agent actions
        if [[ "$line" =~ "Executing"|"Processing"|"Analyzing"|"Generating"|"Building" ]]; then
            # Extract action
            action=$(echo "$line" | sed -E 's/.*(\[[^]]+\]|[A-Z][a-z]+ing[^.]*).*/\1/' | tr -d '[]')

            if [ -n "$current_agent" ]; then
                log_agent_action "$agent_id" "$action" ""
            fi
        fi

        # Detect completion
        if [[ "$line" =~ "completed"|"finished"|"done" ]] && [ -n "$current_agent" ]; then
            log_agent_complete "$agent_id" "success"
            current_agent=""
        fi

        # Detect errors
        if [[ "$line" =~ "error"|"failed"|"ERROR" ]] && [ -n "$current_agent" ]; then
            error_msg=$(echo "$line" | sed -E 's/.*error:?\s*(.+)/\1/i')
            log_agent_error "$agent_id" "$error_msg"
        fi

        # Pass through original output
        echo "$line"
    done
}

# ═══════════════════════════════════════════════════════════════════════════
# Command Execution
# ═══════════════════════════════════════════════════════════════════════════

# Check if this is an agent-spawning command
if [[ "$@" =~ "hive-mind"|"swarm"|"spawn"|"agent" ]]; then
    # Run with agent logging
    $CLAUDE_FLOW_BIN $CLAUDE_FLOW_ARGS "$@" 2>&1 | parse_agent_output
else
    # Run normally
    $CLAUDE_FLOW_BIN $CLAUDE_FLOW_ARGS "$@"
fi
