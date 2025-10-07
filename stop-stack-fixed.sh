#!/bin/bash

echo "Stopping ELK + Jaeger Stack (Fixed Version)..."

# Stop all services
docker-compose -f docker-compose-fixed.yml down

echo "Stack stopped successfully!"

# Show any remaining containers
REMAINING=$(docker ps -a --filter "name=elasticsearch\|kibana\|fluent-bit\|jaeger" --format "table {{.Names}}\t{{.Status}}")
if [ ! -z "$REMAINING" ]; then
    echo ""
    echo "Remaining containers:"
    echo "$REMAINING"
else
    echo "All containers stopped."
fi
