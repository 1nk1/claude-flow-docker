#!/bin/bash
# Verification script for Claude-Flow Docker v1.5

set -e

echo "🔍 Claude-Flow Docker v1.5 - System Verification"
echo "================================================"
echo ""

ERRORS=0
WARNINGS=0
CHECKS=0

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

check_pass() {
    ((CHECKS++))
    echo -e "${GREEN}✅${NC} $1"
}

check_fail() {
    ((CHECKS++))
    ((ERRORS++))
    echo -e "${RED}❌${NC} $1"
}

check_warn() {
    ((CHECKS++))
    ((WARNINGS++))
    echo -e "${YELLOW}⚠️${NC}  $1"
}

echo "1️⃣  Docker Environment"
echo "━━━━━━━━━━━━━━━━━━━━━━"

# Check Docker
if command -v docker &> /dev/null; then
    DOCKER_VERSION=$(docker --version | cut -d' ' -f3 | tr -d ',')
    check_pass "Docker installed: $DOCKER_VERSION"
else
    check_fail "Docker not installed"
fi

# Check Docker Compose
if docker compose version &> /dev/null; then
    COMPOSE_VERSION=$(docker compose version | cut -d' ' -f4)
    check_pass "Docker Compose installed: $COMPOSE_VERSION"
else
    check_fail "Docker Compose not installed"
fi

echo ""
echo "2️⃣  Container Status"
echo "━━━━━━━━━━━━━━━━━━━━━━"

# Check claude-flow container
if docker ps | grep -q claude-flow-alpha; then
    check_pass "claude-flow-alpha container running"
    
    # Check health
    HEALTH=$(docker inspect --format='{{.State.Health.Status}}' claude-flow-alpha 2>/dev/null || echo "none")
    if [ "$HEALTH" == "healthy" ]; then
        check_pass "claude-flow-alpha is healthy"
    elif [ "$HEALTH" == "none" ]; then
        check_warn "claude-flow-alpha has no healthcheck"
    else
        check_fail "claude-flow-alpha is unhealthy: $HEALTH"
    fi
else
    check_fail "claude-flow-alpha not running"
fi

# Check ollama container
if docker ps | grep -q claude-ollama; then
    check_pass "claude-ollama container running"
    
    # Check health
    HEALTH=$(docker inspect --format='{{.State.Health.Status}}' claude-ollama 2>/dev/null || echo "none")
    if [ "$HEALTH" == "healthy" ]; then
        check_pass "claude-ollama is healthy"
    else
        check_warn "claude-ollama health: $HEALTH"
    fi
else
    check_fail "claude-ollama not running"
fi

# Check redis container
if docker ps | grep -q claude-redis; then
    check_pass "claude-redis container running"
    
    # Check health
    HEALTH=$(docker inspect --format='{{.State.Health.Status}}' claude-redis 2>/dev/null || echo "none")
    if [ "$HEALTH" == "healthy" ]; then
        check_pass "claude-redis is healthy"
    else
        check_warn "claude-redis health: $HEALTH"
    fi
else
    check_fail "claude-redis not running"
fi

echo ""
echo "3️⃣  Service Connectivity"
echo "━━━━━━━━━━━━━━━━━━━━━━"

# Test Redis
if docker exec claude-redis redis-cli ping 2>/dev/null | grep -q PONG; then
    check_pass "Redis responding"
else
    check_fail "Redis not responding"
fi

# Test Ollama API
if docker exec claude-ollama curl -s http://localhost:11434/api/tags > /dev/null 2>&1; then
    check_pass "Ollama API responding"
    
    # Count models
    MODEL_COUNT=$(docker exec claude-ollama ollama list 2>/dev/null | tail -n +2 | wc -l)
    if [ "$MODEL_COUNT" -gt 0 ]; then
        check_pass "Ollama has $MODEL_COUNT model(s) installed"
    else
        check_warn "Ollama has no models installed (run init-ollama.sh)"
    fi
else
    check_fail "Ollama API not responding"
fi

# Test Claude-Flow
if docker exec claude-flow-alpha npx claude-flow --version > /dev/null 2>&1; then
    CF_VERSION=$(docker exec claude-flow-alpha npx claude-flow --version 2>/dev/null)
    check_pass "Claude-Flow responding: $CF_VERSION"
else
    check_fail "Claude-Flow not responding"
fi

echo ""
echo "4️⃣  GPU Detection"
echo "━━━━━━━━━━━━━━━━━━━━━━"

# Check for GPU
if [ -f .detected-hardware.env ]; then
    source .detected-hardware.env
    
    if [ "$GPU" != "none" ]; then
        check_pass "GPU detected: $GPU_NAME"
        
        # Verify GPU is accessible from Ollama
        if [ "$GPU" == "amd" ]; then
            if docker exec claude-ollama test -e /dev/kfd 2>/dev/null; then
                check_pass "AMD GPU accessible to Ollama (/dev/kfd)"
            else
                check_fail "AMD GPU not accessible to Ollama"
            fi
        elif [ "$GPU" == "nvidia" ]; then
            if docker exec claude-ollama nvidia-smi > /dev/null 2>&1; then
                check_pass "NVIDIA GPU accessible to Ollama"
            else
                check_fail "NVIDIA GPU not accessible to Ollama"
            fi
        elif [ "$GPU" == "apple_silicon" ]; then
            check_pass "Apple Silicon will use Metal automatically"
        fi
    else
        check_warn "No GPU detected (CPU mode)"
    fi
else
    check_warn "Hardware not detected (run detect-hardware.sh)"
fi

echo ""
echo "5️⃣  Performance Test"
echo "━━━━━━━━━━━━━━━━━━━━━━"

# Test Ollama inference speed
if docker ps | grep -q claude-ollama && [ "$MODEL_COUNT" -gt 0 ]; then
    echo "Testing inference speed..."
    
    START=$(date +%s%3N)
    RESULT=$(docker exec claude-ollama ollama run codellama "print hello" 2>/dev/null || echo "error")
    END=$(date +%s%3N)
    
    if [ "$RESULT" != "error" ]; then
        DURATION=$((END - START))
        if [ "$DURATION" -lt 5000 ]; then
            check_pass "Inference test passed (${DURATION}ms - Fast!)"
        elif [ "$DURATION" -lt 10000 ]; then
            check_pass "Inference test passed (${DURATION}ms - Good)"
        else
            check_warn "Inference test slow (${DURATION}ms)"
        fi
    else
        check_fail "Inference test failed"
    fi
fi

# Test Redis performance
START=$(date +%s%3N)
docker exec claude-redis redis-cli SET test "value" > /dev/null 2>&1
docker exec claude-redis redis-cli GET test > /dev/null 2>&1
END=$(date +%s%3N)
DURATION=$((END - START))

if [ "$DURATION" -lt 100 ]; then
    check_pass "Redis performance test passed (${DURATION}ms)"
else
    check_warn "Redis performance slow (${DURATION}ms)"
fi

echo ""
echo "6️⃣  Configuration Files"
echo "━━━━━━━━━━━━━━━━━━━━━━"

# Check MCP config
if [ -f "config/.claude/settings.json" ]; then
    check_pass "MCP configuration found"
    
    # Validate JSON
    if cat config/.claude/settings.json | jq . > /dev/null 2>&1; then
        check_pass "MCP configuration is valid JSON"
    else
        check_fail "MCP configuration has invalid JSON"
    fi
else
    check_fail "MCP configuration missing"
fi

# Check docker-compose files
if [ -f "docker-compose.v1.5.yml" ]; then
    check_pass "Universal docker-compose found"
else
    check_fail "Universal docker-compose missing"
fi

if [ -f "docker-compose.v1.5-amd.yml" ]; then
    check_pass "AMD docker-compose found"
else
    check_warn "AMD docker-compose missing (not needed for non-AMD)"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 VERIFICATION SUMMARY"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo -e "Total Checks: $CHECKS"
echo -e "${GREEN}Passed:${NC} $((CHECKS - ERRORS - WARNINGS))"
echo -e "${YELLOW}Warnings:${NC} $WARNINGS"
echo -e "${RED}Errors:${NC} $ERRORS"
echo ""

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}🎉 PERFECT! All checks passed!${NC}"
    echo ""
    echo "✅ Claude-Flow v1.5 is ready to use!"
    echo ""
    echo "Next steps:"
    echo "  1. Copy MCP config: cp config/.claude/settings.json ~/.claude/"
    echo "  2. Start Claude Code: claude"
    echo "  3. Test with a prompt"
    echo ""
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠️  WARNINGS FOUND${NC}"
    echo ""
    echo "System is functional but has warnings."
    echo "Review warnings above and fix if needed."
    echo ""
    exit 0
else
    echo -e "${RED}❌ ERRORS FOUND${NC}"
    echo ""
    echo "System has errors that need to be fixed."
    echo "Review errors above and:"
    echo "  1. Make sure all containers are running"
    echo "  2. Check docker logs: docker logs <container-name>"
    echo "  3. Restart services: docker compose restart"
    echo ""
    exit 1
fi
