#!/bin/bash

# Build and run script for Logos Design System examples

set -e  # Exit on error

echo "🎨 Logos Design System - Build and Run"
echo "======================================="
echo ""

if [ ! -f "CMakeLists.txt" ]; then
    echo "❌ Error: CMakeLists.txt not found!"
    echo "Please run this script from the logos-design-system directory."
    exit 1
fi

echo "📁 Creating build directory..."
mkdir -p build
cd build

echo "🔧 Running CMake..."
cmake .. || {
    echo "❌ CMake failed!"
    echo "Make sure Qt 6 is installed and in your PATH."
    exit 1
}

echo "🔨 Building..."
make -j$(sysctl -n hw.ncpu 2>/dev/null || nproc 2>/dev/null || echo 4) || {
    echo "❌ Build failed!"
    exit 1
}

echo ""
echo "✅ Build successful!"
echo ""

if [ ! -f "examples/DesignSystemDemo" ]; then
    echo "❌ Demo executable not found!"
    exit 1
fi

echo "🚀 Launching Design System Demo..."
echo ""
echo "Features:"
echo "  - Click the theme button to toggle light/dark mode"
echo "  - Explore different tabs to see all components"
echo "  - Theme preference is automatically saved"
echo ""

cd examples
./DesignSystemDemo
