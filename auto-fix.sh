#!/bin/bash
# Auto-fix script for Claude-Flow Docker repository

set -e

echo "🔧 Claude-Flow Docker - Auto-Fix Script"
echo "========================================"
echo ""

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}This script will:${NC}"
echo "1. Replace YOUR_USERNAME with your GitHub username"
echo "2. Fix docker-compose to docker compose"
echo "3. Make all scripts executable"
echo "4. Verify all files"
echo ""

# Get GitHub username
read -p "Enter your GitHub username: " GITHUB_USER

if [ -z "$GITHUB_USER" ]; then
    echo -e "${RED}Error: GitHub username cannot be empty${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}Using GitHub username: ${GITHUB_USER}${NC}"
echo ""
read -p "Is this correct? (y/n): " CONFIRM

if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
    echo "Aborted."
    exit 0
fi

echo ""
echo "🔄 Step 1: Replacing YOUR_USERNAME..."
find . -type f \( -name "*.md" -o -name "*.yml" -o -name "*.yaml" -o -name "*.json" \) -not -path "./.git/*" -exec sed -i "s/YOUR_USERNAME/$GITHUB_USER/g" {} \;
echo -e "${GREEN}✅ Replaced YOUR_USERNAME with $GITHUB_USER${NC}"

echo ""
echo "🔄 Step 2: Fixing docker-compose syntax..."
find .github/workflows -type f -name "*.yml" -exec sed -i 's/docker-compose/docker compose/g' {} \;
find tests -type f -name "*.sh" -exec sed -i 's/docker-compose/docker compose/g' {} \; 2>/dev/null || true
echo -e "${GREEN}✅ Fixed docker-compose to docker compose${NC}"

echo ""
echo "🔄 Step 3: Making scripts executable..."
find . -type f -name "*.sh" -not -path "./.git/*" -exec chmod +x {} \;
echo -e "${GREEN}✅ Made all scripts executable${NC}"

echo ""
echo "🔄 Step 4: Verifying fixes..."

# Check if YOUR_USERNAME still exists
REMAINING=$(grep -r "YOUR_USERNAME" . --include="*.md" --include="*.yml" --include="*.json" 2>/dev/null | grep -v "Binary" | wc -l || echo "0")
if [ "$REMAINING" -eq 0 ]; then
    echo -e "${GREEN}✅ No YOUR_USERNAME placeholders remaining${NC}"
else
    echo -e "${YELLOW}⚠️  Warning: Found $REMAINING files with YOUR_USERNAME${NC}"
    echo "Run: grep -r 'YOUR_USERNAME' . --include='*.md' --include='*.yml'"
fi

# Check docker-compose in workflows
if grep -r "docker-compose" .github/workflows/ 2>/dev/null | grep -v "Binary"; then
    echo -e "${YELLOW}⚠️  Warning: docker-compose still found in workflows${NC}"
else
    echo -e "${GREEN}✅ All workflows use 'docker compose'${NC}"
fi

# Check script permissions
NON_EXEC=$(find . -type f -name "*.sh" -not -perm -u+x 2>/dev/null | wc -l)
if [ "$NON_EXEC" -eq 0 ]; then
    echo -e "${GREEN}✅ All scripts are executable${NC}"
else
    echo -e "${YELLOW}⚠️  Warning: $NON_EXEC scripts are not executable${NC}"
fi

echo ""
echo "========================================"
echo -e "${GREEN}🎉 Auto-fix complete!${NC}"
echo ""
echo "✅ Next steps:"
echo "1. Review changes: git diff"
echo "2. Test locally: make setup && make start && make test"
echo "3. Commit: git add . && git commit -m 'fix: Replace placeholders and update config'"
echo "4. Push: git push"
echo ""
echo "Your repository will be ready at:"
echo "https://github.com/$GITHUB_USER/claude-flow-docker"
echo ""
