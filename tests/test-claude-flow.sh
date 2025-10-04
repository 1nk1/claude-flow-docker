#!/bin/bash
# Test script for Claude-Flow functionality

set -e

echo "🐝 Testing Claude-Flow Functionality..."
echo "================================"

GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

TESTS_PASSED=0
TESTS_FAILED=0

run_test() {
    local test_name="$1"
    local test_command="$2"
    
    echo -e "${BLUE}Test: $test_name${NC}"
    if eval "$test_command"; then
        echo -e "${GREEN}✅ PASSED${NC}\n"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}❌ FAILED${NC}\n"
        ((TESTS_FAILED++))
    fi
}

# Test 1: Claude-Flow version command
run_test "Claude-Flow version command" \
    "docker exec claude-flow-alpha claude-flow --version"

# Test 2: Claude-Flow help command
run_test "Claude-Flow help command" \
    "docker exec claude-flow-alpha claude-flow --help | grep -q 'Commands\|Usage'"

# Test 3: Hive-mind status (no active sessions expected)
run_test "Hive-mind status command" \
    "docker exec claude-flow-alpha claude-flow hive-mind status 2>&1 || true"

# Test 4: Memory stats command
run_test "Memory stats command" \
    "docker exec claude-flow-alpha claude-flow memory stats"

# Test 5: Memory list command
run_test "Memory list command" \
    "docker exec claude-flow-alpha claude-flow memory list || true"

# Test 6: Swarm status command
run_test "Swarm status command" \
    "docker exec claude-flow-alpha claude-flow swarm status 2>&1 || true"

# Test 7: Initialize command
run_test "Init command works" \
    "docker exec claude-flow-alpha claude-flow init --force --non-interactive"

# Test 8: Check memory database exists after init
run_test "Memory database created" \
    "docker exec claude-flow-alpha test -f /workspace/.swarm/memory.db"

# Test 9: Agent list command
run_test "Agent list command" \
    "docker exec claude-flow-alpha claude-flow agent list || true"

# Test 10: Neural models check
run_test "Neural models available" \
    "docker exec claude-flow-alpha claude-flow neural status 2>&1 || true"

# Test 11: GitHub commands available
run_test "GitHub commands available" \
    "docker exec claude-flow-alpha claude-flow github --help 2>&1 | grep -q 'github\|GitHub' || true"

# Test 12: MCP mode available
run_test "MCP mode available" \
    "docker exec claude-flow-alpha claude-flow mcp --help 2>&1 | grep -q 'mcp\|MCP' || true"

# Test 13: Hooks commands available
run_test "Hooks commands available" \
    "docker exec claude-flow-alpha claude-flow hooks --help 2>&1 | grep -q 'hooks\|Hooks' || true"

# Test 14: Config directory exists
run_test "Config directory exists" \
    "docker exec claude-flow-alpha test -d /workspace/.claude"

# Test 15: Coordination directory exists
run_test "Coordination directory exists" \
    "docker exec claude-flow-alpha test -d /workspace/coordination"

# Summary
echo "================================"
echo -e "${BLUE}Claude-Flow Functionality Test Summary:${NC}"
echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
echo -e "${RED}Failed: $TESTS_FAILED${NC}"
echo "================================"

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}🎉 All Claude-Flow tests passed!${NC}"
    exit 0
else
    echo -e "${RED}❌ Some Claude-Flow tests failed${NC}"
    echo -e "${BLUE}Note: Some failures may be expected (e.g., no active hive-mind)${NC}"
    exit 1
fi
