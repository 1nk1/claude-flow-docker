#!/bin/bash
# Run claude-flow agent with dashboard logging
# Usage: ./run-agent.sh <agent-type> "<task>"
# Example: ./run-agent.sh researcher "Analyze the codebase structure"

CONTAINER="${CONTAINER_NAME:-claude-flow-alpha}"
AGENT_TYPE="${1:-researcher}"
TASK="${2:-Analyze the project}"
AGENT_ID=$((RANDOM % 9000 + 1000))
AGENT_NAME="${AGENT_TYPE^}Agent"

LOG_FILE="/workspace/logs/agents.log"

echo "Starting agent: $AGENT_NAME (ID=$AGENT_ID)"
echo "Task: $TASK"
echo ""

# Log agent start
docker exec "$CONTAINER" sh -c "echo 'AGENT_START | ID=$AGENT_ID | NAME=$AGENT_NAME | T$(date +%H:%M:%S)' >> $LOG_FILE"

# Log initial action
docker exec "$CONTAINER" sh -c "echo 'AGENT_ACTION | ID=$AGENT_ID | ACTION=initializing | DETAILS=Starting $AGENT_TYPE agent | T$(date +%H:%M:%S)' >> $LOG_FILE"

# Run the actual agent and capture output
docker exec "$CONTAINER" sh -c "
    # Update action to running
    echo 'AGENT_ACTION | ID=$AGENT_ID | ACTION=analyzing | DETAILS=Processing task | T\$(date +%H:%M:%S)' >> $LOG_FILE

    # Run agent
    claude-flow agent run $AGENT_TYPE \"$TASK\" 2>&1 | while IFS= read -r line; do
        echo \"\$line\"
        # Log significant actions
        case \"\$line\" in
            *'Thinking'*|*'thinking'*)
                echo 'AGENT_ACTION | ID=$AGENT_ID | ACTION=thinking | DETAILS=\${line:0:50} | T\$(date +%H:%M:%S)' >> $LOG_FILE
                ;;
            *'Writing'*|*'writing'*|*'Creating'*|*'creating'*)
                echo 'AGENT_ACTION | ID=$AGENT_ID | ACTION=coding | DETAILS=\${line:0:50} | T\$(date +%H:%M:%S)' >> $LOG_FILE
                ;;
            *'Reading'*|*'reading'*|*'Analyzing'*|*'analyzing'*)
                echo 'AGENT_ACTION | ID=$AGENT_ID | ACTION=analyzing | DETAILS=\${line:0:50} | T\$(date +%H:%M:%S)' >> $LOG_FILE
                ;;
            *'Testing'*|*'testing'*|*'Running'*|*'running'*)
                echo 'AGENT_ACTION | ID=$AGENT_ID | ACTION=testing | DETAILS=\${line:0:50} | T\$(date +%H:%M:%S)' >> $LOG_FILE
                ;;
        esac
    done

    # Log completion
    echo 'AGENT_COMPLETE | ID=$AGENT_ID | T\$(date +%H:%M:%S)' >> $LOG_FILE
"

echo ""
echo "Agent $AGENT_NAME (ID=$AGENT_ID) completed"
