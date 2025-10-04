#!/bin/bash
# Complete verification script for Claude-Flow Docker repository

set -e

echo "🔍 Claude-Flow Docker - Complete Verification"
echo "=============================================="
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

ERRORS=0
WARNINGS=0
CHECKS=0

check_file() {
    ((CHECKS++))
    if [ -f "$1" ]; then
        echo -e "${GREEN}✅${NC} $1"
    else
        echo -e "${RED}❌${NC} $1 - MISSING"
        ((ERRORS++))
    fi
}

check_placeholder() {
    ((CHECKS++))
    if grep -q "YOUR_USERNAME" "$1" 2>/dev/null; then
        echo -e "${YELLOW}⚠️${NC}  $1 contains YOUR_USERNAME placeholder"
        ((WARNINGS++))
    else
        echo -e "${GREEN}✅${NC} $1 - No placeholders"
    fi
}

check_docker_compose_syntax() {
    ((CHECKS++))
    if grep -q "docker-compose" "$1" 2>/dev/null; then
        echo -e "${YELLOW}⚠️${NC}  $1 uses docker-compose (should be 'docker compose')"
        ((WARNINGS++))
    else
        echo -e "${GREEN}✅${NC} $1 - Uses 'docker compose'"
    fi
}

check_actions_version() {
    ((CHECKS++))
    local file="$1"
    local action="$2"
    local expected="$3"
    
    if grep -q "${action}@${expected}" "$file" 2>/dev/null; then
        echo -e "${GREEN}✅${NC} $file uses ${action}@${expected}"
    else
        echo -e "${RED}❌${NC} $file doesn't use ${action}@${expected}"
        ((ERRORS++))
    fi
}

echo "📋 1. CHECKING REQUIRED FILES"
echo "================================"

# Core files
check_file "Dockerfile"
check_file "docker-compose.yml"
check_file "docker-entrypoint.sh"
check_file "Makefile"
check_file ".env.example"
check_file "LICENSE"

# Documentation
check_file "README.md"
check_file "QUICKSTART.md"
check_file "INSTALLATION.md"
check_file "INTEGRATION.md"
check_file "TROUBLESHOOTING.md"
check_file "PROJECT_SUMMARY.md"
check_file "CONTRIBUTING.md"
check_file "CHANGELOG.md"
check_file "GITHUB_SETUP.md"
check_file "PACKAGE_README.md"

# GitHub
check_file ".github/workflows/docker-build.yml"
check_file ".github/workflows/mcp-integration.yml"
check_file ".github/workflows/docs.yml"
check_file ".github/ISSUE_TEMPLATE/bug_report.md"
check_file ".github/ISSUE_TEMPLATE/feature_request.md"
check_file ".github/pull_request_template.md"
check_file ".github/markdown-link-check-config.json"

# Tests
check_file "tests/test-docker-build.sh"
check_file "tests/test-mcp-connection.sh"
check_file "tests/test-claude-flow.sh"

# Config
check_file "config/.claude/settings.json"
check_file ".gitignore"
check_file ".dockerignore"

# Scripts
check_file "setup.sh"
check_file "cf-start.sh"
check_file "cf-stop.sh"
check_file "cf-exec.sh"
check_file "cf-logs.sh"
check_file "cf-shell.sh"

echo ""
echo "🔗 2. CHECKING PLACEHOLDERS"
echo "================================"

check_placeholder "README.md"
check_placeholder "QUICKSTART.md"
check_placeholder "INSTALLATION.md"
check_placeholder "INTEGRATION.md"
check_placeholder "TROUBLESHOOTING.md"
check_placeholder "PROJECT_SUMMARY.md"
check_placeholder "CONTRIBUTING.md"
check_placeholder "CHANGELOG.md"
check_placeholder ".github/workflows/docker-build.yml"
check_placeholder ".github/workflows/mcp-integration.yml"
check_placeholder ".github/workflows/docs.yml"

echo ""
echo "🐳 3. CHECKING DOCKER COMPOSE SYNTAX"
echo "================================"

check_docker_compose_syntax ".github/workflows/docker-build.yml"
check_docker_compose_syntax ".github/workflows/mcp-integration.yml"
check_docker_compose_syntax "tests/test-docker-build.sh"
check_docker_compose_syntax "tests/test-mcp-connection.sh"
check_docker_compose_syntax "README.md"
check_docker_compose_syntax "QUICKSTART.md"
check_docker_compose_syntax "INSTALLATION.md"

echo ""
echo "🔄 4. CHECKING GITHUB ACTIONS VERSIONS"
echo "================================"

check_actions_version ".github/workflows/docker-build.yml" "actions/checkout" "v4"
check_actions_version ".github/workflows/docker-build.yml" "actions/upload-artifact" "v4"
check_actions_version ".github/workflows/docker-build.yml" "actions/cache" "v4"
check_actions_version ".github/workflows/docker-build.yml" "docker/setup-buildx-action" "v3"
check_actions_version ".github/workflows/docker-build.yml" "docker/build-push-action" "v5"

check_actions_version ".github/workflows/mcp-integration.yml" "actions/checkout" "v4"
check_actions_version ".github/workflows/mcp-integration.yml" "actions/setup-node" "v4"
check_actions_version ".github/workflows/mcp-integration.yml" "docker/setup-buildx-action" "v3"

check_actions_version ".github/workflows/docs.yml" "actions/checkout" "v4"
check_actions_version ".github/workflows/docs.yml" "actions/setup-node" "v4"

echo ""
echo "📝 5. CHECKING FILE PERMISSIONS"
echo "================================"

for script in *.sh tests/*.sh; do
    if [ -f "$script" ]; then
        if [ -x "$script" ]; then
            echo -e "${GREEN}✅${NC} $script is executable"
        else
            echo -e "${YELLOW}⚠️${NC}  $script is NOT executable"
            ((WARNINGS++))
        fi
        ((CHECKS++))
    fi
done

echo ""
echo "🔧 6. CHECKING CONFIGURATION"
echo "================================"

# Check .env.example
if [ -f ".env.example" ]; then
    ((CHECKS++))
    if grep -q "CONTAINER_NAME=" ".env.example"; then
        echo -e "${GREEN}✅${NC} .env.example has required variables"
    else
        echo -e "${RED}❌${NC} .env.example missing variables"
        ((ERRORS++))
    fi
fi

# Check MCP config
if [ -f "config/.claude/settings.json" ]; then
    ((CHECKS++))
    if grep -q "mcpServers" "config/.claude/settings.json"; then
        echo -e "${GREEN}✅${NC} MCP config has servers"
    else
        echo -e "${RED}❌${NC} MCP config missing servers"
        ((ERRORS++))
    fi
    
    ((CHECKS++))
    if grep -q "hooks" "config/.claude/settings.json"; then
        echo -e "${GREEN}✅${NC} MCP config has hooks"
    else
        echo -e "${RED}❌${NC} MCP config missing hooks"
        ((ERRORS++))
    fi
fi

echo ""
echo "📦 7. CHECKING DOCKER FILES"
echo "================================"

# Check Dockerfile
if [ -f "Dockerfile" ]; then
    ((CHECKS++))
    if grep -q "FROM node:22-alpine" "Dockerfile"; then
        echo -e "${GREEN}✅${NC} Dockerfile uses Node 22"
    else
        echo -e "${RED}❌${NC} Dockerfile wrong Node version"
        ((ERRORS++))
    fi
    
    ((CHECKS++))
    if grep -q "better-sqlite3" "Dockerfile"; then
        echo -e "${GREEN}✅${NC} Dockerfile builds better-sqlite3"
    else
        echo -e "${YELLOW}⚠️${NC}  Dockerfile may not build better-sqlite3"
        ((WARNINGS++))
    fi
fi

# Check docker-compose.yml
if [ -f "docker-compose.yml" ]; then
    ((CHECKS++))
    if grep -q "healthcheck:" "docker-compose.yml"; then
        echo -e "${GREEN}✅${NC} docker-compose has healthcheck"
    else
        echo -e "${YELLOW}⚠️${NC}  docker-compose missing healthcheck"
        ((WARNINGS++))
    fi
    
    ((CHECKS++))
    if grep -q "volumes:" "docker-compose.yml"; then
        echo -e "${GREEN}✅${NC} docker-compose has volumes"
    else
        echo -e "${RED}❌${NC} docker-compose missing volumes"
        ((ERRORS++))
    fi
fi

echo ""
echo "📊 SUMMARY"
echo "================================"
echo -e "${BLUE}Total checks:${NC} $CHECKS"
echo -e "${GREEN}Passed:${NC} $((CHECKS - ERRORS - WARNINGS))"
echo -e "${YELLOW}Warnings:${NC} $WARNINGS"
echo -e "${RED}Errors:${NC} $ERRORS"
echo ""

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}🎉 PERFECT! All checks passed!${NC}"
    echo "Ready to push to GitHub! 🚀"
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠️  WARNINGS FOUND${NC}"
    echo "You should fix warnings before pushing."
    echo "Run this script again after fixes."
    exit 0
else
    echo -e "${RED}❌ ERRORS FOUND${NC}"
    echo "Fix errors before pushing to GitHub!"
    exit 1
fi
