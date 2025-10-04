#!/bin/bash
# Fix all broken links and username inconsistencies

set -e

echo "🔧 Fixing broken links and usernames..."

# Remove or comment out links to non-existent pages
echo "1. Removing links to non-existent pages (wiki, discussions, releases)..."

# Fix README.md - remove docker-test.yml badge
sed -i '/docker-test\.yml/d' README.md

# Fix all markdown files - remove links to wiki, discussions, releases
find . -name "*.md" -exec sed -i \
  -e 's|\[GitHub Issues\](https://github.com/[^/]*/claude-flow-docker/issues)|[GitHub Issues](https://github.com/YOUR_USERNAME/claude-flow-docker/issues)|g' \
  -e 's|\[GitHub Discussions\](https://github.com/[^/]*/claude-flow-docker/discussions)|<!--[GitHub Discussions](https://github.com/YOUR_USERNAME/claude-flow-docker/discussions)-->|g' \
  -e 's|\[Documentation\](https://github.com/[^/]*/claude-flow-docker/wiki)|<!--[Documentation](https://github.com/YOUR_USERNAME/claude-flow-docker/wiki)-->|g' \
  -e 's|https://github.com/[^/]*/claude-flow-docker/releases|https://github.com/YOUR_USERNAME/claude-flow-docker/releases/tag/v1.0.0|g' \
  -e 's|https://github.com/[^/]*/claude-flow-docker/wiki|https://github.com/YOUR_USERNAME/claude-flow-docker|g' \
  -e 's|https://github.com/[^/]*/claude-flow-docker/discussions|https://github.com/YOUR_USERNAME/claude-flow-docker|g' \
  {} \;

echo "✅ Fixed broken links"

# Normalize all usernames
echo "2. Normalizing usernames..."
find . -name "*.md" -exec sed -i \
  -e 's|adjkas/claude-flow-docker|YOUR_USERNAME/claude-flow-docker|g' \
  -e 's|1nk1kas/claude-flow-docker|YOUR_USERNAME/claude-flow-docker|g' \
  -e 's|1nk1/claude-flow-docker|YOUR_USERNAME/claude-flow-docker|g' \
  {} \;

echo "✅ Normalized usernames to YOUR_USERNAME"

echo ""
echo "Done! Now run: ./auto-fix.sh to set your real username"
