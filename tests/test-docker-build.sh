#!/bin/bash
# Test script for Docker build validation

set -e

echo " Testing Docker Build..."
echo "================================"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

# Helper function for tests
run_test() {
    local test_name="$1"
    local test_command="$2"

    echo -e "${BLUE}Test: $test_name${NC}"
    if eval "$test_command"; then
        echo -e "${GREEN} PASSED${NC}\n"
        ((TESTS_PASSED++))
    else
        echo -e "${RED} FAILED${NC}\n"
        ((TESTS_FAILED++))
    fi
}

# Test 1: Container exists
run_test "Container exists" \
    "docker ps -a | grep -q claude-flow-alpha"

# Test 2: Container is running
run_test "Container is running" \
    "docker ps | grep -q claude-flow-alpha"

# Test 3: Node.js version is 22
run_test "Node.js version is 22" \
    "docker exec claude-flow-alpha node --version | grep -q 'v22'"

# Test 4: Claude Code installed
run_test "Claude Code is installed" \
    "docker exec claude-flow-alpha which claude"

# Test 5: Claude-Flow installed
run_test "Claude-Flow is installed" \
    "docker exec claude-flow-alpha claude-flow --version"

# Test 6: better-sqlite3 works
run_test "better-sqlite3 module works" \
    "docker exec claude-flow-alpha node -e \"require('better-sqlite3'); console.log('OK')\""

# Test 7: Working directory correct
run_test "Working directory is /workspace" \
    "docker exec claude-flow-alpha pwd | grep -q '/workspace'"

# Test 8: Required directories exist
run_test "Required directories exist" \
    "docker exec claude-flow-alpha test -d /workspace/.hive-mind && \
     docker exec claude-flow-alpha test -d /workspace/.swarm && \
     docker exec claude-flow-alpha test -d /workspace/memory && \
     docker exec claude-flow-alpha test -d /workspace/coordination"

# Test 9: npm global packages location
run_test "npm global packages accessible" \
    "docker exec claude-flow-alpha npm list -g --depth=0 | grep -q 'claude-flow'"

# Test 10: Git installed
run_test "Git is installed" \
    "docker exec claude-flow-alpha git --version"

# Test 11: Python installed
run_test "Python3 is installed" \
    "docker exec claude-flow-alpha python3 --version"

# Test 12: SQLite installed
run_test "SQLite is installed" \
    "docker exec claude-flow-alpha sqlite3 --version"

# Test 13: Healthcheck configured
run_test "Healthcheck is configured" \
    "docker inspect claude-flow-alpha | grep -q 'Healthcheck'"

# Test 14: Environment variables set
run_test "Environment variables are set" \
    "docker exec claude-flow-alpha printenv | grep -q 'CLAUDE_FLOW_HOME'"

# Test 15: Entrypoint script exists
run_test "Entrypoint script exists" \
    "docker exec claude-flow-alpha test -f /usr/local/bin/docker-entrypoint.sh"

# Summary
echo "================================"
echo -e "${BLUE}Test Summary:${NC}"
echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
echo -e "${RED}Failed: $TESTS_FAILED${NC}"
echo "================================"

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN} All tests passed!${NC}"
    exit 0
else
    echo -e "${RED} Some tests failed${NC}"
    exit 1
fi
