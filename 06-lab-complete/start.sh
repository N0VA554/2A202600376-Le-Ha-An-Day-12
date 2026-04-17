#!/bin/bash
# Railway start script for production AI agent
set -e

echo "Starting AI Agent on Railway..."
echo "PORT: $PORT"
echo "REDIS_URL: $REDIS_URL"
echo "AGENT_API_KEY: ${AGENT_API_KEY:0:10}..."
echo "Current directory: $(pwd)"
echo "Files in directory:"
ls -la

# Use PORT if set, otherwise default to 8000
PORT=${PORT:-8000}
echo "Using port: $PORT"

# Test if we can import the app
echo "Testing Python imports..."
python -c "import sys; print('Python path:', sys.path)"
python -c "from app.main import app; print('App imported successfully')" || echo "Import failed!"

echo "Starting uvicorn..."
# Start the application
exec uvicorn app.main:app --host 0.0.0.0 --port $PORT --workers 1 --log-level info