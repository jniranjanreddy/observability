# ELK + Jaeger Observability Stack

Complete observability stack with Elasticsearch, Kibana, Fluent Bit, and Jaeger for logs and distributed tracing.

## 🚀 Quick Start

### Prerequisites
- Docker and Docker Compose installed
- WSL2 (if on Windows)
- At least 4GB RAM available for containers

### Start the Stack
```bash
# Make scripts executable
chmod +x *.sh

# Start with the fixed configuration (recommended)
./start-stack-fixed.sh

# Or use the simple version
./start-stack.sh
```

### Access Services
- **Elasticsearch**: http://localhost:9200
- **Kibana**: http://localhost:5601
- **Fluent Bit**: http://localhost:2020
- **Jaeger UI**: http://localhost:16686

## 📁 Directory Structure

```
observability/
├── docker-compose.yml              # Full configuration
├── docker-compose-simple.yml       # Minimal configuration
├── docker-compose-fixed.yml        # Fixed Kibana permissions
├── config/
│   ├── fluent-bit.conf             # Fluent Bit configuration
│   ├── parsers.conf                # Log parsers
│   ├── elasticsearch.yml           # Elasticsearch settings
│   ├── kibana.yml                  # Kibana settings
│   └── kibana-minimal.yml          # Minimal Kibana config
├── examples/
│   └── java-tracing-example.java   # OpenTelemetry integration
├── start-stack.sh                  # Start script
├── start-stack-fixed.sh            # Fixed start script
├── stop-stack.sh                   # Stop script
├── stop-stack-fixed.sh             # Fixed stop script
└── cleanup.sh                      # Cleanup script
```

## 🔧 Configuration Options

### 1. Fixed Configuration (Recommended)
Uses `docker-compose-fixed.yml` with minimal Kibana config to avoid permission issues.

### 2. Simple Configuration
Uses `docker-compose-simple.yml` with default settings and no custom config files.

### 3. Full Configuration
Uses `docker-compose.yml` with all custom configurations.

## 🐛 Troubleshooting

### Kibana Permission Issues
If you see permission errors for `/var/log/kibana`, use the fixed configuration:
```bash
./start-stack-fixed.sh
```

### View Logs
```bash
# View all logs
docker-compose -f docker-compose-fixed.yml logs -f

# View specific service logs
docker-compose -f docker-compose-fixed.yml logs -f kibana
docker-compose -f docker-compose-fixed.yml logs -f elasticsearch
```

### Health Checks
```bash
# Check Elasticsearch
curl http://localhost:9200/_cluster/health

# Check Kibana status
curl http://localhost:5601/api/status

# Check Fluent Bit metrics
curl http://localhost:2020/api/v1/metrics
```

## 📊 Using the Stack

### 1. Set up Kibana Index Patterns
1. Open http://localhost:5601
2. Go to Management → Stack Management → Index Patterns
3. Create pattern: `fluent-bit-*`
4. Select `@timestamp` as time field

### 2. View Traces in Jaeger
1. Open http://localhost:16686
2. Select a service from the dropdown
3. Click "Find Traces"

### 3. Correlate Logs and Traces
Look for `trace_id` and `span_id` fields in your application logs to correlate with Jaeger traces.

## 🛑 Stopping the Stack

```bash
# Stop services
./stop-stack-fixed.sh

# Or clean up everything (removes data)
./cleanup.sh
```

## 📝 Notes

- The stack uses about 2-3GB of RAM
- Data is persisted in Docker volumes
- All services run on localhost with different ports
- Security is disabled for development use only
