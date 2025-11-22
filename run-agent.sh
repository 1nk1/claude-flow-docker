#!/bin/bash
# Run claude-flow agent with dashboard logging
# Usage: ./run-agent.sh <agent-type> "<task>" [provider]
# Example: ./run-agent.sh researcher "Analyze the codebase structure" gemini

CONTAINER="${CONTAINER_NAME:-claude-flow-alpha}"
AGENT_TYPE="${1:-researcher}"
TASK="${2:-Analyze the project}"
PROVIDER="${3:-${AGENT_PROVIDER:-anthropic}}"
AGENT_ID=$((RANDOM % 9000 + 1000))
# Capitalize first letter without bash 4+ syntax
AGENT_NAME="$(echo "$AGENT_TYPE" | awk '{print toupper(substr($0,1,1)) substr($0,2)}')Agent"

LOG_FILE="/workspace/logs/agents.log"

echo "Starting agent: $AGENT_NAME (ID=$AGENT_ID)"
echo "Task: $TASK"
echo "Provider: $PROVIDER"
echo ""

# Log agent start
docker exec "$CONTAINER" sh -c "echo 'AGENT_START | ID=$AGENT_ID | NAME=$AGENT_NAME | T$(date +%H:%M:%S)' >> $LOG_FILE"

# Log initial action
docker exec "$CONTAINER" sh -c "echo 'AGENT_ACTION | ID=$AGENT_ID | ACTION=initializing | DETAILS=Starting $AGENT_TYPE agent | T$(date +%H:%M:%S)' >> $LOG_FILE"

# Run the actual agent
docker exec "$CONTAINER" sh -c "
    echo 'AGENT_ACTION | ID=$AGENT_ID | ACTION=analyzing | DETAILS=Processing task | T\$(date +%H:%M:%S)' >> $LOG_FILE

    # Run agent with specified provider
    claude-flow agent run $AGENT_TYPE \"$TASK\" --provider $PROVIDER 2>&1 | while IFS= read -r line; do
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
