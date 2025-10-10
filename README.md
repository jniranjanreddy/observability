# ELK + Jaeger Observability Stack

Complete observability stack with Elasticsearch, Kibana, Fluent Bit, and Jaeger for logs and distributed tracing.

## 🚀 Quick Start
```
Day-1 https://www.youtube.com/watch?v=otY2_M_pTmU&list=PLdpzxOOAlwvJUIfwmmVDoPYqXXUNbdBmb&index=1
day-2 https://www.youtube.com/watch?v=OfoQMJJSnUs&list=PLdpzxOOAlwvJUIfwmmVDoPYqXXUNbdBmb&index=3
Day-3 https://www.youtube.com/watch?v=2IfyyteAc5g&list=PLdpzxOOAlwvJUIfwmmVDoPYqXXUNbdBmb&index=3
Day-4 https://www.youtube.com/watch?v=uEFwvEw9H9E&list=PLdpzxOOAlwvJUIfwmmVDoPYqXXUNbdBmb&index=4
Day-5 https://www.youtube.com/watch?v=HGTBANm0VY4&list=PLdpzxOOAlwvJUIfwmmVDoPYqXXUNbdBmb&index=5
Day-6 https://www.youtube.com/watch?v=U9qInvWTe9w&list=PLdpzxOOAlwvJUIfwmmVDoPYqXXUNbdBmb&index=6


```

## Opentelemetry
```

```

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


## Fluentbit workflow
<img width="1344" height="1131" alt="image" src="https://github.com/user-attachments/assets/4abe29f4-6111-4dca-9544-25d56ae34c07" />

## step-1 Where Fluent Bit Reads Logs From
```
Fluent Bit runs as a DaemonSet, so one pod runs per node to collect logs from all containers on that node.
Kubernetes stores container logs on each node under:
/var/log/containers/*.log
/var/log/containers/myapp-7c9d8c5b5b-mgzqj_default_myapp-12345.log


Inside each line you’ll see something like:
{"log":"User login successful\n","stream":"stdout","time":"2025-10-08T14:12:45.123456789Z"}


```
## Step-2 Fluent Bit Tail Input Plugin (collects container logs)
```
In Fluent Bit’s config inside the DaemonSet, you’ll find something like:
[INPUT]
    Name              tail
    Path              /var/log/containers/*.log
    Parser            docker
    Tag               kube.*
    Refresh_Interval  5
    Mem_Buf_Limit     5MB
    Skip_Long_Lines   On
    DB                /var/fluent-bit/state/flb_kube.db


```
## Step 3: Kubernetes Filter (adds metadata)
```
Fluent Bit enriches logs using Kubernetes metadata (like pod name, namespace, container name, labels).
[FILTER]
    Name                kubernetes
    Match               kube.*
    Kube_URL            https://kubernetes.default.svc:443
    Merge_Log           On
    Keep_Log            Off
    K8S-Logging.Parser  On
    K8S-Logging.Exclude On


This filter:

Queries the Kubernetes API to get metadata for each log line.

Adds fields like:
{
  "kubernetes": {
    "pod_name": "myapp-7c9d8c5b5b-mgzqj",
    "namespace_name": "default",
    "container_name": "myapp",
    "labels": {
      "app": "myapp"
    }
  }
}


```
Step 4: Output Plugin — Send to Elasticsearch
```
Finally, Fluent Bit sends logs to Elasticsearch (or OpenSearch):
[OUTPUT]
    Name            es
    Match           kube.*
    Host            elasticsearch.logging.svc.cluster.local
    Port            9200
    Index           kubernetes-logs
    Type            _doc
    Logstash_Format On
    HTTP_User       elastic
    HTTP_Passwd     your_password
    tls             On

It batches log records and sends them using Elasticsearch’s _bulk API.

```
## Step 5: Fluent Bit DaemonSet YAML Example
```
Here’s how the DaemonSet might look (simplified):
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: fluent-bit
  namespace: logging
spec:
  selector:
    matchLabels:
      app: fluent-bit
  template:
    metadata:
      labels:
        app: fluent-bit
    spec:
      serviceAccountName: fluent-bit
      containers:
        - name: fluent-bit
          image: fluent/fluent-bit:3.0
          volumeMounts:
            - name: varlog
              mountPath: /var/log
            - name: varlibdockercontainers
              mountPath: /var/lib/docker/containers
              readOnly: true
            - name: config
              mountPath: /fluent-bit/etc/
      volumes:
        - name: varlog
          hostPath:
            path: /var/log
        - name: varlibdockercontainers
          hostPath:
            path: /var/lib/docker/containers
        - name: config
          configMap:
            name: fluent-bit-config

The ConfigMap provides the [SERVICE], [INPUT], [FILTER], and [OUTPUT] sections discussed earlier.
```
## Data Flow Inside Kubernetes

```
App Pod → writes to /var/log/containers/
              │
Fluent Bit (DaemonSet, on same node)
              │
 [INPUT: tail] → [FILTER: kubernetes] → [OUTPUT: es]
              │
Elasticsearch (Deployment or external)

```
## Example Elasticsearch Output (after ingestion)
```
{
  "log": "GET /api/user 200",
  "kubernetes": {
    "pod_name": "myapp-7c9d8c5b5b-mgzqj",
    "namespace_name": "default",
    "container_name": "myapp",
    "labels": { "app": "myapp" }
  },
  "@timestamp": "2025-10-08T14:12:45.123Z"
}

```


















