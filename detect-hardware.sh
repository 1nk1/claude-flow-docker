#!/bin/bash
# Hardware detection script for Claude-Flow Docker v1.5

set -e

echo "🔍 Detecting hardware configuration..."
echo ""

# Detect OS
OS="unknown"
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
fi

echo "Operating System: $OS"

# Detect GPU
GPU="none"
GPU_NAME=""

if [[ "$OS" == "macos" ]]; then
    # Check for Apple Silicon
    if [[ $(uname -m) == "arm64" ]]; then
        GPU="apple_silicon"
        GPU_NAME=$(sysctl -n machdep.cpu.brand_string)
        echo "✅ Apple Silicon detected: $GPU_NAME"
        echo "   GPU Acceleration: Metal"
    else
        echo "ℹ️  Intel Mac detected (no Metal support)"
        GPU="none"
    fi
    
elif [[ "$OS" == "linux" ]]; then
    # Check for NVIDIA
    if command -v nvidia-smi &> /dev/null; then
        GPU="nvidia"
        GPU_NAME=$(nvidia-smi --query-gpu=name --format=csv,noheader | head -n1)
        echo "✅ NVIDIA GPU detected: $GPU_NAME"
        echo "   GPU Acceleration: CUDA"
        echo "   Driver Version: $(nvidia-smi --query-gpu=driver_version --format=csv,noheader | head -n1)"
        
    # Check for AMD with ROCm
    elif command -v rocm-smi &> /dev/null; then
        GPU="amd"
        GPU_NAME=$(rocm-smi --showproductname 2>/dev/null | grep -A1 "GPU" | tail -n1 | tr -d '[:space:]')
        echo "✅ AMD GPU detected: $GPU_NAME"
        echo "   GPU Acceleration: ROCm"
        ROCM_VERSION=$(cat /opt/rocm/.info/version 2>/dev/null || echo "unknown")
        echo "   ROCm Version: $ROCM_VERSION"
        
    # Check for AMD without ROCm
    elif lspci | grep -i "vga.*amd\|vga.*radeon" &> /dev/null; then
        GPU="amd_no_rocm"
        GPU_NAME=$(lspci | grep -i "vga.*amd\|vga.*radeon" | cut -d: -f3 | tr -d '[:space:]')
        echo "⚠️  AMD GPU detected: $GPU_NAME"
        echo "   ⚠️  ROCm NOT installed - GPU acceleration disabled"
        echo "   To enable GPU: Install ROCm first"
        echo "   Guide: https://docs.amd.com/bundle/ROCm-Installation-Guide-v5.7/page/Introduction_to_ROCm_Installation_Guide.html"
    fi
fi

# Detect CPU
CPU_CORES=$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo "unknown")
echo ""
echo "CPU Cores: $CPU_CORES"

# Detect RAM
if [[ "$OS" == "macos" ]]; then
    RAM_GB=$(($(sysctl -n hw.memsize) / 1024 / 1024 / 1024))
elif [[ "$OS" == "linux" ]]; then
    RAM_GB=$(free -g | awk '/^Mem:/{print $2}')
fi
echo "RAM: ${RAM_GB}GB"

# Recommendations
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 RECOMMENDED CONFIGURATION"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

case $GPU in
    "apple_silicon")
        echo "✅ Best Setup: Universal Configuration"
        echo "   File: docker-compose.v1.5.yml"
        echo "   Features:"
        echo "   • Automatic Metal acceleration"
        echo "   • Optimal for Apple Silicon"
        echo "   • No additional configuration needed"
        echo ""
        echo "📊 Expected Performance:"
        echo "   • llama2-7b: ~40 tokens/sec"
        echo "   • codellama-13b: ~25 tokens/sec"
        echo "   • mistral-7b: ~45 tokens/sec"
        COMPOSE_FILE="docker-compose.v1.5.yml"
        ;;
        
    "nvidia")
        echo "✅ Best Setup: Universal Configuration"
        echo "   File: docker-compose.v1.5.yml"
        echo "   Features:"
        echo "   • Automatic CUDA acceleration"
        echo "   • Optimal for NVIDIA GPUs"
        echo "   • No additional configuration needed"
        echo ""
        echo "📊 Expected Performance:"
        echo "   • llama2-7b: ~50-80 tokens/sec"
        echo "   • codellama-13b: ~30-50 tokens/sec"
        echo "   • mistral-7b: ~80-120 tokens/sec"
        COMPOSE_FILE="docker-compose.v1.5.yml"
        ;;
        
    "amd")
        echo "✅ Best Setup: AMD-Optimized Configuration"
        echo "   File: docker-compose.v1.5-amd.yml"
        echo "   Features:"
        echo "   • ROCm GPU acceleration"
        echo "   • Optimized for AMD GPUs"
        echo "   • 24GB VRAM support (for large models)"
        echo ""
        if [[ "$GPU_NAME" == *"7900"* ]]; then
            echo "🔥 EXCELLENT CHOICE! RX 7900 series detected"
            echo "   You can run 70B models locally!"
            echo ""
            echo "📊 Expected Performance:"
            echo "   • llama2-70b: ~30 tokens/sec"
            echo "   • codellama-34b: ~35 tokens/sec"
            echo "   • mistral-7b: ~120 tokens/sec"
        else
            echo "📊 Expected Performance:"
            echo "   • llama2-7b: ~40-60 tokens/sec"
            echo "   • codellama-13b: ~25-40 tokens/sec"
            echo "   • mistral-7b: ~60-100 tokens/sec"
        fi
        COMPOSE_FILE="docker-compose.v1.5-amd.yml"
        ;;
        
    "amd_no_rocm")
        echo "⚠️  Setup: Universal Configuration (CPU fallback)"
        echo "   File: docker-compose.v1.5.yml"
        echo ""
        echo "❗ GPU Detected but ROCm Not Installed"
        echo "   Your AMD GPU won't be used without ROCm"
        echo ""
        echo "To enable GPU acceleration:"
        echo "1. Install ROCm:"
        echo "   wget https://repo.radeon.com/amdgpu-install/latest/ubuntu/jammy/amdgpu-install_6.0.60000-1_all.deb"
        echo "   sudo dpkg -i amdgpu-install_6.0.60000-1_all.deb"
        echo "   sudo amdgpu-install --usecase=rocm"
        echo ""
        echo "2. Add user to groups:"
        echo "   sudo usermod -a -G render,video \$USER"
        echo "   newgrp render"
        echo ""
        echo "3. Rerun this script"
        echo "4. Use docker-compose.v1.5-amd.yml"
        echo ""
        echo "📊 Current Performance (CPU only):"
        echo "   • llama2-7b: ~5-10 tokens/sec"
        echo "   • codellama-7b: ~8-12 tokens/sec"
        echo "   • mistral-7b: ~10-15 tokens/sec"
        COMPOSE_FILE="docker-compose.v1.5.yml"
        ;;
        
    "none")
        echo "ℹ️  Setup: Universal Configuration (CPU mode)"
        echo "   File: docker-compose.v1.5.yml"
        echo "   Features:"
        echo "   • CPU-optimized inference"
        echo "   • SIMD acceleration"
        echo "   • No GPU required"
        echo ""
        echo "📊 Expected Performance:"
        echo "   • llama2-7b: ~5-10 tokens/sec"
        echo "   • codellama-7b: ~8-12 tokens/sec"
        echo "   • mistral-7b: ~10-15 tokens/sec"
        echo ""
        echo "💡 Tip: Still useful for caching and smart routing!"
        COMPOSE_FILE="docker-compose.v1.5.yml"
        ;;
esac

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 NEXT STEPS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "1. Start services:"
echo "   docker compose -f $COMPOSE_FILE up -d"
echo ""
echo "2. Initialize Ollama models:"
echo "   ./init-ollama.sh"
echo ""
echo "3. Verify installation:"
echo "   ./verify-v1.5.sh"
echo ""
echo "4. Start using:"
echo "   cd ~/your-project"
echo "   cp config/.claude/settings.json ./.claude/"
echo "   claude"
echo ""

# Save detected config
cat > .detected-hardware.env << EOF
# Auto-detected hardware configuration
# Generated: $(date)
OS=$OS
GPU=$GPU
GPU_NAME=$GPU_NAME
CPU_CORES=$CPU_CORES
RAM_GB=${RAM_GB}
COMPOSE_FILE=$COMPOSE_FILE
EOF

echo "✅ Hardware detection complete!"
echo "   Configuration saved to: .detected-hardware.env"
echo ""
