#!/bin/bash
# Railway start script for production AI agent
set -e

echo "Starting AI Agent on Railway..."
echo "PORT: $PORT"
echo "REDIS_URL: $REDIS_URL"

# Start the application
exec uvicorn app.main:app --host 0.0.0.0 --port $PORT --workers 1