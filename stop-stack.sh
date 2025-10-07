#!/bin/bash

echo "Stopping ELK + Jaeger Stack..."

# Stop all services
docker-compose down

# Optional: Remove volumes (uncomment if you want to clean up data)
# echo "Removing volumes..."
# docker-compose down -v

echo "Stack stopped successfully!"

# Show any remaining containers
REMAINING=$(docker ps -a --filter "label=com.docker.compose.project" --format "table {{.Names}}\t{{.Status}}")
if [ ! -z "$REMAINING" ]; then
    echo ""
    echo "Remaining containers:"
    echo "$REMAINING"
fi