#!/bin/bash

# Focus List Backend Startup Script
echo "🚀 Starting Focus List Backend..."

# Check if virtual environment exists
if [ ! -d "venv" ]; then
    echo "❌ Virtual environment not found. Please run setup first."
    exit 1
fi

# Activate virtual environment
echo "📦 Activating virtual environment..."
source venv/bin/activate

# Check if dependencies are installed
if ! pip show flask > /dev/null 2>&1; then
    echo "📥 Installing dependencies..."
    pip install -r requirements.txt
fi

# Start the server
echo "🌐 Starting Flask server..."
python app.py
