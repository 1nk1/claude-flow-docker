#!/bin/bash
# Run claude-flow agent with dashboard logging (using ONNX - free local inference)
# Usage: ./run-agent.sh <agent-type> "<task>"
# Example: ./run-agent.sh researcher "Analyze the codebase structure"

CONTAINER="${CONTAINER_NAME:-claude-flow-alpha}"
AGENT_TYPE="${1:-researcher}"
TASK="${2:-Analyze the project}"
AGENT_ID=$((RANDOM % 9000 + 1000))
# Capitalize first letter without bash 4+ syntax
AGENT_NAME="$(echo "$AGENT_TYPE" | awk '{print toupper(substr($0,1,1)) substr($0,2)}')Agent"

LOG_FILE="/workspace/logs/agents.log"

echo "Starting agent: $AGENT_NAME (ID=$AGENT_ID)"
echo "Task: $TASK"
echo "Provider: ONNX (free local inference)"
echo ""

# Log agent start
docker exec "$CONTAINER" sh -c "echo 'AGENT_START | ID=$AGENT_ID | NAME=$AGENT_NAME | T$(date +%H:%M:%S)' >> $LOG_FILE"

# Log initial action
docker exec "$CONTAINER" sh -c "echo 'AGENT_ACTION | ID=$AGENT_ID | ACTION=initializing | DETAILS=Starting $AGENT_TYPE agent | T$(date +%H:%M:%S)' >> $LOG_FILE"

# Run the actual agent with ONNX provider (free, no API key needed)
docker exec "$CONTAINER" sh -c "
    echo 'AGENT_ACTION | ID=$AGENT_ID | ACTION=analyzing | DETAILS=Processing task with ONNX | T\$(date +%H:%M:%S)' >> $LOG_FILE

    # Run agent with --provider onnx for free local inference
    claude-flow agent run $AGENT_TYPE \"$TASK\" --provider onnx 2>&1 | while IFS= read -r line; do
        echo \"\$line\"
        case \"\$line\" in
            *'Thinking'*|*'thinking'*)
                echo \"AGENT_ACTION | ID=$AGENT_ID | ACTION=thinking | DETAILS=Processing | T\$(date +%H:%M:%S)\" >> $LOG_FILE
                ;;
            *'Writing'*|*'writing'*|*'Creating'*|*'creating'*)
                echo \"AGENT_ACTION | ID=$AGENT_ID | ACTION=coding | DETAILS=Writing code | T\$(date +%H:%M:%S)\" >> $LOG_FILE
                ;;
            *'Reading'*|*'reading'*|*'Analyzing'*|*'analyzing'*)
                echo \"AGENT_ACTION | ID=$AGENT_ID | ACTION=analyzing | DETAILS=Analyzing | T\$(date +%H:%M:%S)\" >> $LOG_FILE
                ;;
            *'Testing'*|*'testing'*|*'Running'*|*'running'*)
                echo \"AGENT_ACTION | ID=$AGENT_ID | ACTION=testing | DETAILS=Testing | T\$(date +%H:%M:%S)\" >> $LOG_FILE
                ;;
            *'Error'*|*'error'*|*'failed'*)
                echo \"AGENT_ACTION | ID=$AGENT_ID | ACTION=error | DETAILS=Error occurred | T\$(date +%H:%M:%S)\" >> $LOG_FILE
                ;;
        esac
    done

    echo 'AGENT_COMPLETE | ID=$AGENT_ID | T\$(date +%H:%M:%S)' >> $LOG_FILE
"

echo ""
echo "Agent $AGENT_NAME (ID=$AGENT_ID) completed"
