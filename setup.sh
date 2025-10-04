#!/bin/bash
# Setup script для Claude-Flow Docker environment

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "🔧 Claude-Flow Docker Setup"
echo "======================================"

# Проверка зависимостей
echo "1️⃣  Checking dependencies..."
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

echo "✅ Dependencies check passed"

# Создание директорий
echo ""
echo "2️⃣  Creating project structure..."
mkdir -p project config/.claude logs

# Копирование .env файла
if [ ! -f ".env" ]; then
    echo "📝 Creating .env file..."
    cp .env.example .env
    echo "✅ .env file created. Please review and update if needed."
else
    echo "✅ .env file already exists"
fi

# Создание .dockerignore
echo ""
echo "3️⃣  Creating .dockerignore..."
cat > .dockerignore <<'EOF'
node_modules
npm-debug.log
.git
.gitignore
.env
*.md
.DS_Store
logs
*.log
coverage
.nyc_output
EOF
echo "✅ .dockerignore created"

# Создание .gitignore
echo ""
echo "4️⃣  Creating .gitignore..."
cat > .gitignore <<'EOF'
# Environment
.env
.env.local

# Logs
logs
*.log

# Docker volumes
project/*
!project/.gitkeep

# OS files
.DS_Store
Thumbs.db

# IDE
.vscode/*
!.vscode/settings.json
.idea
EOF
echo "✅ .gitignore created"

# Создание project/.gitkeep
touch project/.gitkeep

# Build Docker image
echo ""
echo "5️⃣  Building Docker image..."
docker-compose build

echo ""
echo "======================================"
echo "✅ Setup completed successfully!"
echo ""
echo "📋 Next steps:"
echo "   1. Review and update .env file if needed"
echo "   2. Copy your project files to ./project/ directory"
echo "   3. Run: ./cf-start.sh to start Claude-Flow"
echo "   4. Copy config/.claude/settings.json to your project root"
echo ""
echo "🔗 Quick commands:"
echo "   ./cf-start.sh  - Start Claude-Flow container"
echo "   ./cf-stop.sh   - Stop Claude-Flow container"
echo "   ./cf-exec.sh   - Execute commands in container"
echo "   ./cf-logs.sh   - View container logs"
echo ""
echo "======================================"
