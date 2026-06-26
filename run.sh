#!/bin/bash
set -e

mkdir -p /data

echo "[choreboard] Starting backend on :5050..."
cd /app
uvicorn main:app --host 127.0.0.1 --port 5050 --workers 1 &
BACKEND_PID=$!

# Wait for backend to be ready
for i in $(seq 1 10); do
    if curl -sf http://127.0.0.1:5050/health > /dev/null 2>&1; then
        break
    fi
    sleep 0.5
done

echo "[choreboard] Starting nginx on :8099..."
exec nginx -g "daemon off;"
