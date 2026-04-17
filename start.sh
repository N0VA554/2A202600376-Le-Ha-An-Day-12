#!/bin/bash
# Railway start script
cd /app
exec uvicorn app.main:app --host 0.0.0.0 --port $PORT --workers 2