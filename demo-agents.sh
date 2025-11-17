#!/bin/bash
# Demo script to showcase agent visualization

echo "Starting agent visualization demo..."

# Source the agent logger
docker exec claude-flow-alpha bash -c 'source /workspace/lib/agent-logger.sh && {

# Start 8 different agents
log_agent_start 0 "CoordinatorAgent" "coordinator"
sleep 0.5

log_agent_start 1 "ResearchAgent" "researcher"
sleep 0.5

log_agent_start 2 "CoderAgent" "coder"
sleep 0.5

log_agent_start 3 "ReviewAgent" "reviewer"
sleep 0.5

log_agent_start 4 "TesterAgent" "tester"
sleep 0.5

log_agent_start 5 "OptimizerAgent" "optimizer"
sleep 0.5

log_agent_start 6 "DesignerAgent" "designer"
sleep 0.5

log_agent_start 7 "PlannerAgent" "planner"
sleep 1

# Simulate some actions
log_agent_action 0 "Analyzing project requirements" "Initial analysis phase"
sleep 0.3

log_agent_action 1 "Searching documentation for best practices" "Found 15 relevant docs"
sleep 0.3

log_agent_action 2 "Implementing authentication module" "Using JWT tokens"
sleep 0.3

log_agent_action 3 "Reviewing authentication code" "Checking security patterns"
sleep 0.3

log_agent_action 4 "Running unit tests" "23 tests passing"
sleep 0.3

log_agent_action 5 "Analyzing performance metrics" "Response time: 45ms"
sleep 0.3

log_agent_action 6 "Creating UI mockups" "Designed 3 screens"
sleep 0.3

log_agent_action 7 "Planning sprint backlog" "15 user stories ready"
sleep 0.3

log_agent_action 0 "Coordinating team efforts" "All agents synced"
sleep 0.3

log_agent_action 2 "Refactoring authentication logic" "Improved error handling"
sleep 0.3

# Complete some agents
log_agent_complete 1 "Research completed successfully"
sleep 0.3

log_agent_complete 6 "Design mockups ready for review"
sleep 0.3

log_agent_complete 7 "Sprint plan finalized"
sleep 0.3

# Simulate an error
log_agent_error 4 "Test failed: Invalid token format"
sleep 0.5

# More actions
log_agent_action 2 "Fixing token validation" "Added format check"
sleep 0.3

log_agent_action 4 "Re-running tests" "All tests passing now"
sleep 0.3

log_agent_complete 4 "Testing completed successfully"
sleep 0.3

log_agent_complete 2 "Authentication module complete"
sleep 0.3

log_agent_complete 3 "Code review approved"
sleep 0.3

log_agent_complete 5 "Performance optimization done"
sleep 0.3

log_agent_complete 0 "Coordination completed - All tasks done"
sleep 1

# Show final status
echo ""
echo "═══════════════════════════════════════════════════════════════"
show_active_agents
}'

echo ""
echo "Demo complete! Check the logs:"
echo "  docker logs claude-flow-alpha"
echo "  docker exec claude-flow-alpha tail -50 /workspace/logs/agents.log"
echo ""
echo "Or use make commands:"
echo "  make agents          # View active agents"
echo "  make agents-logs     # Follow agent logs"
echo "  make agents-tail     # Last 50 lines"
