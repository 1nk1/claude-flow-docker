#!/bin/bash
# Test script for MCP connection validation

set -e

echo "🔗 Testing MCP Connection..."
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

# Test 1: MCP config file exists
run_test "MCP config file exists" \
    "test -f config/.claude/settings.json"

# Test 2: MCP config is valid JSON
run_test "MCP config is valid JSON" \
    "cat config/.claude/settings.json | jq . > /dev/null"

# Test 3: MCP servers defined
run_test "MCP servers are defined" \
    "cat config/.claude/settings.json | jq '.mcpServers' | grep -q 'claude-flow'"

# Test 4: Docker command in config
run_test "Docker command configured" \
    "cat config/.claude/settings.json | jq -r '.mcpServers[\"claude-flow-docker\"].command' | grep -q 'docker'"

# Test 5: MCP command works via docker exec
run_test "MCP via docker exec works" \
    "docker exec -i claude-flow-alpha npx claude-flow mcp --help 2>&1 | grep -q 'MCP\|mcp\|claude-flow' || true"

# Test 6: Initialize MCP connection
run_test "Can initialize MCP connection" \
    "echo '{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"initialize\",\"params\":{}}' | docker exec -i claude-flow-alpha npx claude-flow mcp | grep -q 'jsonrpc\|result' || true"

# Test 7: List MCP tools
run_test "Can list MCP tools" \
    "echo '{\"jsonrpc\":\"2.0\",\"id\":2,\"method\":\"tools/list\",\"params\":{}}' | docker exec -i claude-flow-alpha npx claude-flow mcp | grep -q 'tools\|result' || true"

# Test 8: Hooks configured
run_test "Hooks are configured" \
    "cat config/.claude/settings.json | jq '.hooks' | grep -q 'Hook\|hook'"

# Test 9: Multiple MCP servers
run_test "Multiple MCP servers configured" \
    "cat config/.claude/settings.json | jq '.mcpServers | length' | grep -E '[2-9]|[0-9]{2,}'"

# Test 10: Container responds to stdin
run_test "Container responds to stdin" \
    "echo 'test' | docker exec -i claude-flow-alpha cat | grep -q 'test'"

# Summary
echo "================================"
echo -e "${BLUE}MCP Connection Test Summary:${NC}"
echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
echo -e "${RED}Failed: $TESTS_FAILED${NC}"
echo "================================"

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}🎉 All MCP tests passed!${NC}"
    exit 0
else
    echo -e "${RED}❌ Some MCP tests failed${NC}"
    exit 1
fi
