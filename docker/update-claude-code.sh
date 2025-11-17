#!/bin/bash

# Claude Code Update Script for Docker Container
# This script updates Claude Code inside the claude-flow-alpha container

set -e

CONTAINER_NAME="claude-flow-alpha"
BACKUP_DIR="/Users/a.peretiatkofavbet.tech/projects/ai-rules-core/src/docker/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Claude Code Update Script${NC}"
echo -e "${GREEN}Container: ${CONTAINER_NAME}${NC}"
echo -e "${GREEN}========================================${NC}"

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

# Function to test MCP connection
test_mcp_connection() {
    echo -e "${YELLOW}Testing MCP connection...${NC}"
    if docker exec -i ${CONTAINER_NAME} claude-flow mcp start --test 2>/dev/null; then
        echo -e "${GREEN}✓ MCP connection test passed${NC}"
        return 0
    else
        echo -e "${YELLOW}⚠ MCP connection test failed or not available${NC}"
        return 1
    fi
}

# Main execution
main() {
    echo -e "\n${YELLOW}Step 1: Checking container status...${NC}"
    check_container
    echo -e "${GREEN}✓ Container is running${NC}"

    echo -e "\n${YELLOW}Step 2: Checking current version...${NC}"
    CURRENT_VERSION=$(get_current_version)
    echo -e "Current version: ${GREEN}${CURRENT_VERSION}${NC}"

    echo -e "\n${YELLOW}Step 3: Checking latest available version...${NC}"
    LATEST_VERSION=$(docker exec ${CONTAINER_NAME} npm view @anthropic-ai/claude-code version 2>/dev/null || echo "Unable to fetch")
    echo -e "Latest version: ${GREEN}${LATEST_VERSION}${NC}"

    if [ "${CURRENT_VERSION}" = "${LATEST_VERSION}" ]; then
        echo -e "\n${GREEN}✓ Already running the latest version!${NC}"
        exit 0
    fi

    echo -e "\n${YELLOW}Step 4: Creating backup information...${NC}"
    mkdir -p "${BACKUP_DIR}"
    BACKUP_FILE="${BACKUP_DIR}/claude-code-version-${TIMESTAMP}.txt"
    echo "Claude Code Version Backup - ${TIMESTAMP}" > "${BACKUP_FILE}"
    echo "Container: ${CONTAINER_NAME}" >> "${BACKUP_FILE}"
    echo "Version: ${CURRENT_VERSION}" >> "${BACKUP_FILE}"
    docker exec ${CONTAINER_NAME} npm list -g @anthropic-ai/claude-code >> "${BACKUP_FILE}" 2>/dev/null || true
    echo -e "${GREEN}✓ Backup info saved to ${BACKUP_FILE}${NC}"

    echo -e "\n${YELLOW}Step 5: Updating Claude Code...${NC}"
    echo -e "${YELLOW}Note: This may require sudo permissions inside the container${NC}"

    # Try without sudo first, then with sudo if it fails
    if docker exec ${CONTAINER_NAME} npm install -g @anthropic-ai/claude-code@latest 2>/dev/null; then
        echo -e "${GREEN}✓ Update completed successfully${NC}"
    elif docker exec -u root ${CONTAINER_NAME} npm install -g @anthropic-ai/claude-code@latest; then
        echo -e "${GREEN}✓ Update completed successfully (using root)${NC}"
    else
        echo -e "${RED}✗ Update failed${NC}"
        echo -e "${YELLOW}Try running manually with: docker exec -u root ${CONTAINER_NAME} npm install -g @anthropic-ai/claude-code@latest${NC}"
        exit 1
    fi

    echo -e "\n${YELLOW}Step 6: Verifying new version...${NC}"
    NEW_VERSION=$(get_current_version)
    echo -e "New version: ${GREEN}${NEW_VERSION}${NC}"

    echo -e "\n${YELLOW}Step 7: Testing MCP integration...${NC}"
    test_mcp_connection || true

    echo -e "\n${GREEN}========================================${NC}"
    echo -e "${GREEN}Update Summary:${NC}"
    echo -e "  Previous version: ${YELLOW}${CURRENT_VERSION}${NC}"
    echo -e "  New version: ${GREEN}${NEW_VERSION}${NC}"
    echo -e "  Backup saved to: ${BACKUP_FILE}"
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}✓ Update completed successfully!${NC}\n"
}

# Run main function
main "$@"