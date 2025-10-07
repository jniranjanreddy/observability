#!/bin/bash

echo "Starting ELK + Jaeger Stack (Fixed Version)..."

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    echo "Error: Docker is not running. Please start Docker Desktop."
    exit 1
fi

# Clean up any existing containers first
echo "Cleaning up existing containers..."
docker-compose -f docker-compose-fixed.yml down -v 2>/dev/null || true

# Wait a moment
sleep 2

echo "Starting services with fixed configuration..."

# Start the stack with the fixed configuration
docker-compose -f docker-compose-fixed.yml up -d

echo "Waiting for services to start..."
sleep 20

# Check service health
echo "Checking service health..."

# Check Elasticsearch
echo -n "Elasticsearch: "
if curl -s http://localhost:9200/_cluster/health >/dev/null 2>&1; then
    echo "✅ Running"
else
    echo "❌ Not responding"
fi

# Check Kibana
echo -n "Kibana: "
if curl -s http://localhost:5601/api/status >/dev/null 2>&1; then
    echo "✅ Running"
else
    echo "❌ Not responding (may still be starting)"
fi

# Check Fluent Bit
echo -n "Fluent Bit: "
if curl -s http://localhost:2020/api/v1/metrics >/dev/null 2>&1; then
    echo "✅ Running"
else
    echo "❌ Not responding"
fi

# Check Jaeger
echo -n "Jaeger: "
if curl -s http://localhost:16686/api/services >/dev/null 2>&1; then
    echo "✅ Running"
else
    echo "❌ Not responding"
fi

echo ""
echo "🌐 Access URLs:"
echo "- Elasticsearch: http://localhost:9200"
echo "- Kibana: http://localhost:5601"
echo "- Fluent Bit: http://localhost:2020"
echo "- Jaeger UI: http://localhost:16686"
echo ""
echo "📊 To view logs:"
echo "docker-compose -f docker-compose-fixed.yml logs -f [service_name]"
echo ""
echo "🛑 To stop:"
echo "./stop-stack-fixed.sh"
