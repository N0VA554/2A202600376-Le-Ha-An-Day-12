#!/bin/bash
# Railway start script for production AI agent
set -e

echo "Starting AI Agent on Railway..."
echo "PORT: $PORT"
echo "REDIS_URL: $REDIS_URL"
echo "AGENT_API_KEY: ${AGENT_API_KEY:0:10}..."

# Use PORT if set, otherwise default to 8000
PORT=${PORT:-8000}

echo "Using port: $PORT"

# Start the application
exec uvicorn app.main:app --host 0.0.0.0 --port $PORT --workers 1 --log-level info