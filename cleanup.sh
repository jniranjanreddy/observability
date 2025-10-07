#!/bin/bash

echo "Cleaning up ELK + Jaeger Stack..."

# Stop and remove all containers
echo "Stopping containers..."
docker-compose down -v

# Remove any orphaned containers
echo "Removing orphaned containers..."
docker container prune -f

# Remove any unused volumes
echo "Removing unused volumes..."
docker volume prune -f

# Remove any unused networks
echo "Removing unused networks..."
docker network prune -f

echo "Cleanup completed!"

# Show remaining containers (if any)
REMAINING=$(docker ps -a --format "table {{.Names}}\t{{.Status}}")
if [ ! -z "$REMAINING" ]; then
    echo ""
    echo "Remaining containers:"
    echo "$REMAINING"
else
    echo "No containers remaining."
fi
