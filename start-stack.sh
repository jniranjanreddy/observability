#!/bin/bash

echo "Starting ELK + Jaeger Stack..."

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    echo "Error: Docker is not running. Please start Docker Desktop."
    exit 1
fi

# Check if configuration files exist
if [ ! -f "config/fluent-bit.conf" ]; then
    echo "Error: config/fluent-bit.conf not found!"
    exit 1
fi

if [ ! -f "config/parsers.conf" ]; then
    echo "Error: config/parsers.conf not found!"
    exit 1
fi

echo "Configuration files found. Starting services..."

# Start the stack
docker-compose up -d

echo "Waiting for services to start..."
sleep 15

# Check service health
echo "Checking service health..."

# Check Elasticsearch
if curl -s http://localhost:9200/_cluster/health >/dev/null; then
    echo "✅ Elasticsearch is running"
else
    echo "❌ Elasticsearch is not responding"
fi

# Check Kibana
if curl -s http://localhost:5601/api/status >/dev/null; then
    echo "✅ Kibana is running"
else
    echo "❌ Kibana is not responding (may still be starting up)"
fi

# Check Fluent Bit
if curl -s http://localhost:2020/api/v1/metrics >/dev/null; then
    echo "✅ Fluent Bit is running"
else
    echo "❌ Fluent Bit is not responding"
fi

# Check Jaeger
if curl -s http://localhost:16686/api/services >/dev/null; then
    echo "✅ Jaeger is running"
else
    echo "❌ Jaeger is not responding"
fi

echo ""
echo "Access URLs:"
echo "- Elasticsearch: http://localhost:9200"
echo "- Kibana: http://localhost:5601"
echo "- Fluent Bit: http://localhost:2020"
echo "- Jaeger UI: http://localhost:16686"
echo ""
echo "To stop the stack: ./stop-stack.sh"
echo "To view logs: docker-compose logs -f [service_name]"