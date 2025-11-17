#!/bin/bash

# Script to check all Claude-related versions in the container

CONTAINER_NAME="claude-flow-alpha"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Claude Components Version Check${NC}"
echo -e "${GREEN}Container: ${CONTAINER_NAME}${NC}"
echo -e "${GREEN}========================================${NC}\n"

# Check if container is running
if ! docker ps | grep -q "${CONTAINER_NAME}"; then
    echo -e "${RED}Error: Container ${CONTAINER_NAME} is not running${NC}"
    exit 1
fi

# Claude Code version
echo -e "${BLUE}Claude Code:${NC}"
docker exec ${CONTAINER_NAME} claude --version 2>/dev/null || echo "  Not installed"
echo

# Claude Flow version
echo -e "${BLUE}Claude Flow:${NC}"
docker exec ${CONTAINER_NAME} claude-flow --version 2>/dev/null || echo "  Not installed"
echo

# NPM packages
echo -e "${BLUE}NPM Global Packages:${NC}"
docker exec ${CONTAINER_NAME} npm list -g --depth=0 2>/dev/null | grep -E "@anthropic-ai/claude-code|claude-flow" || echo "  No Claude packages found"
echo

# Latest available versions
echo -e "${YELLOW}Latest Available Versions:${NC}"
echo -n "  Claude Code: "
docker exec ${CONTAINER_NAME} npm view @anthropic-ai/claude-code version 2>/dev/null || echo "Unable to fetch"
echo -n "  Claude Flow: "
docker exec ${CONTAINER_NAME} npm view claude-flow version 2>/dev/null || echo "Unable to fetch"
echo

# Node.js version
echo -e "${BLUE}Node.js:${NC}"
docker exec ${CONTAINER_NAME} node --version 2>/dev/null || echo "  Not available"
echo

# NPM version
echo -e "${BLUE}NPM:${NC}"
docker exec ${CONTAINER_NAME} npm --version 2>/dev/null || echo "  Not available"
echo

echo -e "${GREEN}========================================${NC}"