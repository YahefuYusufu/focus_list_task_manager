#!/bin/bash

# Focus List Backend Setup Script
echo "🔧 Setting up Focus List Backend..."

# Check Python version
python3 --version || {
    echo "❌ Python 3 not found. Please install Python 3.8+"
    exit 1
}

# Create virtual environment
echo "📦 Creating virtual environment..."
python3 -m venv venv

# Activate virtual environment
echo "📦 Activating virtual environment..."
source venv/bin/activate

# Install dependencies
echo "📥 Installing dependencies..."
pip install -r requirements.txt

# Test the installation
echo "🧪 Testing installation..."
python -c "import flask; print('✅ Flask installed successfully')"

echo "✅ Setup complete! Run './start_server.sh' to start the server."
