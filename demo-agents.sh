#!/bin/bash
# Demo script to simulate agents for dashboard testing
# This creates fake agent activity to test the live-dashboard.sh

CONTAINER="${CONTAINER_NAME:-claude-flow-alpha}"
LOG_FILE="/workspace/logs/agents.log"

echo "Starting demo agents simulation..."
echo "Open ./live-dashboard.sh in another terminal to see them"
echo ""

# Create log file
docker exec "$CONTAINER" sh -c "mkdir -p /workspace/logs && touch $LOG_FILE"

# Simulate 3 agents
simulate_agent() {
    local ID=$1
    local NAME=$2
    local ACTIONS=("analyzing" "thinking" "coding" "testing" "refactoring" "reviewing")

    # Start agent
    docker exec "$CONTAINER" sh -c "echo 'AGENT_START | ID=$ID | NAME=$NAME | T$(date +%H:%M:%S)' >> $LOG_FILE"
    echo "Started $NAME (ID=$ID)"

    # Random actions
    for i in {1..5}; do
        sleep $((RANDOM % 3 + 1))
        ACTION=${ACTIONS[$((RANDOM % ${#ACTIONS[@]}))]}
        DETAIL="Processing step $i..."
        docker exec "$CONTAINER" sh -c "echo 'AGENT_ACTION | ID=$ID | ACTION=$ACTION | DETAILS=$DETAIL | T$(date +%H:%M:%S)' >> $LOG_FILE"
        echo "  $NAME: $ACTION - $DETAIL"
    done
}

# Start agents
ID1=$((RANDOM % 9000 + 1000))
ID2=$((RANDOM % 9000 + 1000))
ID3=$((RANDOM % 9000 + 1000))

simulate_agent $ID1 "FlutterTestAgent" &
PID1=$!
sleep 1
simulate_agent $ID2 "CodeReviewAgent" &
PID2=$!
sleep 1
simulate_agent $ID3 "ResearcherAgent" &
PID3=$!

# Wait for all to finish
wait $PID1 $PID2 $PID3

# Complete agents
sleep 2
docker exec "$CONTAINER" sh -c "echo 'AGENT_COMPLETE | ID=$ID1 | T$(date +%H:%M:%S)' >> $LOG_FILE"
docker exec "$CONTAINER" sh -c "echo 'AGENT_COMPLETE | ID=$ID2 | T$(date +%H:%M:%S)' >> $LOG_FILE"
docker exec "$CONTAINER" sh -c "echo 'AGENT_COMPLETE | ID=$ID3 | T$(date +%H:%M:%S)' >> $LOG_FILE"

echo ""
echo "Demo completed! All agents finished."
echo "Check the dashboard to see the results."
