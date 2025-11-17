#!/bin/bash

# Claude Code Rollback Script for Docker Container
# This script rolls back Claude Code to a specific version

set -e

CONTAINER_NAME="claude-flow-alpha"
ROLLBACK_VERSION="${1:-2.0.21}"  # Default to the current known working version

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}Claude Code Rollback Script${NC}"
echo -e "${YELLOW}Container: ${CONTAINER_NAME}${NC}"
echo -e "${YELLOW}Target Version: ${ROLLBACK_VERSION}${NC}"
echo -e "${YELLOW}========================================${NC}"

# Function to check if container is running
check_container() {
    if ! docker ps | grep -q "${CONTAINER_NAME}"; then
        echo -e "${RED}Error: Container ${CONTAINER_NAME} is not running${NC}"
        exit 1
    fi
}

# Function to get current version
get_current_version() {
    docker exec ${CONTAINER_NAME} claude --version 2>/dev/null | head -n 1 || echo "Unknown"
}

# Main execution
main() {
    echo -e "\n${YELLOW}Step 1: Checking container status...${NC}"
    check_container
    echo -e "${GREEN}✓ Container is running${NC}"

    echo -e "\n${YELLOW}Step 2: Checking current version...${NC}"
    CURRENT_VERSION=$(get_current_version)
    echo -e "Current version: ${YELLOW}${CURRENT_VERSION}${NC}"

    read -p "$(echo -e ${YELLOW}Do you want to rollback to version ${ROLLBACK_VERSION}? [y/N]: ${NC})" -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${RED}Rollback cancelled${NC}"
        exit 0
    fi

    echo -e "\n${YELLOW}Step 3: Rolling back Claude Code...${NC}"
    if docker exec ${CONTAINER_NAME} npm install -g @anthropic-ai/claude-code@${ROLLBACK_VERSION}; then
        echo -e "${GREEN}✓ Rollback completed successfully${NC}"
    else
        echo -e "${RED}✗ Rollback failed${NC}"
        exit 1
    fi

    echo -e "\n${YELLOW}Step 4: Verifying rollback...${NC}"
    NEW_VERSION=$(get_current_version)
    echo -e "Version after rollback: ${GREEN}${NEW_VERSION}${NC}"

    echo -e "\n${YELLOW}Step 5: Testing MCP connection...${NC}"
    if docker exec -i ${CONTAINER_NAME} claude-flow mcp start --test 2>/dev/null; then
        echo -e "${GREEN}✓ MCP connection test passed${NC}"
    else
        echo -e "${YELLOW}⚠ MCP connection test failed or not available${NC}"
    fi

    echo -e "\n${GREEN}========================================${NC}"
    echo -e "${GREEN}Rollback completed!${NC}"
    echo -e "  Previous version: ${YELLOW}${CURRENT_VERSION}${NC}"
    echo -e "  Rolled back to: ${GREEN}${NEW_VERSION}${NC}"
    echo -e "${GREEN}========================================${NC}\n"
}

# Check if version was provided as argument
if [ $# -eq 0 ]; then
    echo -e "${YELLOW}No version specified. Using default: ${ROLLBACK_VERSION}${NC}"
    echo -e "${YELLOW}Usage: $0 <version>${NC}"
    echo -e "${YELLOW}Example: $0 2.0.20${NC}\n"
fi

# Run main function
main "$@"