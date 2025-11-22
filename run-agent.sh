#!/bin/bash
# Run Claude Code agent with dashboard logging
# Uses Claude Code CLI (requires authentication, NO API keys)
# Usage: ./run-agent.sh <agent-type> "<task>"
# Example: ./run-agent.sh researcher "Analyze the codebase structure"

CONTAINER="${CONTAINER_NAME:-claude-flow-alpha}"
AGENT_TYPE="${1:-researcher}"
TASK="${2:-Analyze the project}"
AGENT_ID=$((RANDOM % 9000 + 1000))
AGENT_NAME="$(echo "$AGENT_TYPE" | awk '{print toupper(substr($0,1,1)) substr($0,2)}')Agent"

LOG_FILE="/workspace/logs/agents.log"

echo "Starting agent: $AGENT_NAME (ID=$AGENT_ID)"
echo "Task: $TASK"
echo "Using: Claude Code (authenticated session)"
echo ""

# Log agent start
docker exec "$CONTAINER" sh -c "echo 'AGENT_START | ID=$AGENT_ID | NAME=$AGENT_NAME | T$(date +%H:%M:%S)' >> $LOG_FILE"

# Build prompt based on agent type
case "$AGENT_TYPE" in
    researcher)
        PROMPT="You are a researcher agent. Research and analyze: $TASK"
        ;;
    coder)
        PROMPT="You are a coding agent. Write code for: $TASK"
        ;;
    tester)
        PROMPT="You are a testing agent. Create tests for: $TASK"
        ;;
    reviewer)
        PROMPT="You are a code review agent. Review: $TASK"
        ;;
    analyst)
        PROMPT="You are an analyst agent. Analyze: $TASK"
        ;;
    architect)
        PROMPT="You are an architecture agent. Design: $TASK"
        ;;
    *)
        PROMPT="$TASK"
        ;;
esac

# Log initial action
docker exec "$CONTAINER" sh -c "echo 'AGENT_ACTION | ID=$AGENT_ID | ACTION=initializing | DETAILS=Starting Claude Code | T$(date +%H:%M:%S)' >> $LOG_FILE"

# Run Claude Code with the task (uses authenticated session)
docker exec -it "$CONTAINER" sh -c "
    echo 'AGENT_ACTION | ID=$AGENT_ID | ACTION=thinking | DETAILS=Processing request | T\$(date +%H:%M:%S)' >> $LOG_FILE

    # Run claude with print mode for non-interactive
    claude -p \"$PROMPT\" 2>&1 | while IFS= read -r line; do
        echo \"\$line\"
    done

    echo 'AGENT_COMPLETE | ID=$AGENT_ID | T\$(date +%H:%M:%S)' >> $LOG_FILE
"

echo ""
echo "Agent $AGENT_NAME (ID=$AGENT_ID) completed"
