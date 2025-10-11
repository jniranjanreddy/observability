## http://github.com/iam-veeramalla/observability-zero-to-hero
## https://docs.fluentbit.io/manual/about/sandbox-and-lab-resources


```
day-1. https://www.youtube.com/watch?v=otY2_M_pTmU&list=PLdpzxOOAlwvJUIfwmmVDoPYqXXUNbdBmb
## 3 pillars of observability
   1. Metrics
   2. Logging
   3. Traces

1. https://www.youtube.com/watch?v=otY2_M_pTmU&list=PLdpzxOOAlwvJUIfwmmVDoPYqXXUNbdBmb
2. 

```
```
docker-compose ps

# Test Elasticsearch
curl http://localhost:9200/_cluster/health

# Test Kibana (wait a minute for it to start)
curl http://localhost:5601/api/status

# Test Fluent Bit
curl http://localhost:2020/api/v1/metrics

# Test Jaeger
curl http://localhost:16686/api/services
```
