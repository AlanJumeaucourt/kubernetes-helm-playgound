#!/bin/bash

PORT=${1:-8081}
echo "Starting port forwarding on port $PORT..."
echo "Press Ctrl+C to stop"

# Check if xdg-open, open, or start command exists (for Linux, macOS, Windows)
if command -v xdg-open &> /dev/null; then
    OPEN_CMD="xdg-open"
elif command -v open &> /dev/null; then
    OPEN_CMD="open"
elif command -v start &> /dev/null; then
    OPEN_CMD="start"
else
    OPEN_CMD=""
    echo "No command found to open browser. Please open http://localhost:$PORT manually."
fi

# Start port forwarding in the background
kubectl port-forward service/todo-frontend $PORT:80 &
PF_PID=$!

# Wait a bit for port forwarding to establish
sleep 2

# Open browser if command exists
if [ -n "$OPEN_CMD" ]; then
    echo "Opening browser..."
    $OPEN_CMD "http://localhost:$PORT"
fi

# Wait for user to press Ctrl+C
echo "Port forwarding active. Press Ctrl+C to stop."
wait $PF_PID

# Make script executable
chmod +x "$(dirname "${BASH_SOURCE[0]}")/open-app.sh"
