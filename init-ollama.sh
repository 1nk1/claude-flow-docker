#!/bin/bash
# Ollama model initialization script

set -e

echo "🦙 Initializing Ollama models..."
echo ""

# Check if Ollama container is running
if ! docker ps | grep -q claude-ollama; then
    echo "❌ Error: claude-ollama container is not running"
    echo "   Start it first: docker compose -f docker-compose.v1.5*.yml up -d"
    exit 1
fi

# Wait for Ollama to be ready
echo "⏳ Waiting for Ollama to be ready..."
for i in {1..30}; do
    if docker exec claude-ollama curl -s http://localhost:11434/api/tags > /dev/null 2>&1; then
        echo "✅ Ollama is ready!"
        break
    fi
    if [ $i -eq 30 ]; then
        echo "❌ Timeout waiting for Ollama"
        exit 1
    fi
    sleep 2
done

echo ""
echo "📥 Downloading models (this may take 10-30 minutes)..."
echo ""

# Array of models to download
declare -a models=(
    "codellama:7b|Code generation and analysis|~4GB"
    "mistral:7b|Fast general-purpose model|~4GB"
    "llama2:7b|Meta's LLaMA 2 7B|~4GB"
)

# Check available disk space
AVAILABLE_SPACE=$(df -BG $(docker volume inspect claude-flow-docker-github_ollama-data --format '{{.Mountpoint}}' 2>/dev/null || echo "/var/lib/docker") | tail -1 | awk '{print $4}' | tr -d 'G')

echo "💾 Available disk space: ${AVAILABLE_SPACE}GB"
echo "   Required: ~15GB for all models"
echo ""

if [ "$AVAILABLE_SPACE" -lt 15 ]; then
    echo "⚠️  Warning: Low disk space!"
    echo "   You may not be able to download all models"
    echo ""
fi

# Download each model
for model_info in "${models[@]}"; do
    IFS='|' read -r model desc size <<< "$model_info"
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📦 Model: $model"
    echo "   Description: $desc"
    echo "   Size: $size"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    # Check if model already exists
    if docker exec claude-ollama ollama list | grep -q "$model"; then
        echo "✅ $model already installed, skipping..."
    else
        echo "⏬ Downloading $model..."
        if docker exec claude-ollama ollama pull "$model"; then
            echo "✅ $model downloaded successfully!"
        else
            echo "❌ Failed to download $model"
            echo "   Continuing with other models..."
        fi
    fi
    echo ""
done

# Optionally download larger models for powerful GPUs
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 OPTIONAL: Large Models (for GPUs with 16GB+ VRAM)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if we're on AMD with sufficient VRAM
if [ -f .detected-hardware.env ]; then
    source .detected-hardware.env
    if [[ "$GPU" == "amd" ]] && [[ "$GPU_NAME" == *"7900"* ]]; then
        echo "✅ High-end AMD GPU detected!"
        echo "   Your RX 7900 XT can handle larger models"
        echo ""
        
        read -p "Download codellama:34b (~20GB, requires 16GB+ VRAM)? (y/N): " download_34b
        if [[ "$download_34b" =~ ^[Yy]$ ]]; then
            echo "⏬ Downloading codellama:34b..."
            docker exec claude-ollama ollama pull codellama:34b
            echo "✅ codellama:34b downloaded!"
        fi
        
        echo ""
        read -p "Download llama2:70b (~40GB, requires 24GB VRAM)? (y/N): " download_70b
        if [[ "$download_70b" =~ ^[Yy]$ ]]; then
            echo "⏬ Downloading llama2:70b..."
            docker exec claude-ollama ollama pull llama2:70b
            echo "✅ llama2:70b downloaded!"
        fi
    fi
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Ollama Initialization Complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# List installed models
echo "📋 Installed models:"
docker exec claude-ollama ollama list
echo ""

# Test a model
echo "🧪 Testing codellama model..."
TEST_RESULT=$(docker exec claude-ollama ollama run codellama "print hello world in rust" --verbose 2>&1 | tail -5)
echo "$TEST_RESULT"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎯 Quick Commands"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Test a model:"
echo "  docker exec claude-ollama ollama run codellama 'your prompt'"
echo ""
echo "List models:"
echo "  docker exec claude-ollama ollama list"
echo ""
echo "Remove a model:"
echo "  docker exec claude-ollama ollama rm model:tag"
echo ""
echo "Pull more models:"
echo "  docker exec claude-ollama ollama pull model:tag"
echo ""
echo "Available models: https://ollama.ai/library"
echo ""

# Save initialization state
cat > .ollama-initialized << EOF
# Ollama initialization complete
# Date: $(date)
# Models installed: $(docker exec claude-ollama ollama list | wc -l)
EOF

echo "✅ Ready to use Claude-Flow with Ollama!"
echo ""
