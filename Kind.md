## elasticsearch
```
helm install elasticsearch elastic/elasticsearch --namespace logging -f values.yaml
NAME: elasticsearch
LAST DEPLOYED: Sat Oct 11 14:56:59 2025
NAMESPACE: logging
STATUS: deployed
REVISION: 1
NOTES:
1. Watch all cluster members come up.
  $ kubectl get pods --namespace=logging -l app=elasticsearch-master -w
2. Retrieve elastic user's password.
  $ kubectl get secrets --namespace=logging elasticsearch-master-credentials -ojsonpath='{.data.password}' | base64 -d
3. Test cluster health using Helm test.
  $ helm --namespace=logging test elasticsearch
```
# fluent-bit

```
helm install fluent-bit fluent/fluent-bit --namespace logging -f fluent-bint-values.yaml
NAME: fluent-bit
LAST DEPLOYED: Sat Oct 11 15:07:27 2025
NAMESPACE: logging
STATUS: deployed
REVISION: 1
NOTES:
Get Fluent Bit build information by running these commands:

export POD_NAME=$(kubectl get pods --namespace logging -l "app.kubernetes.io/name=fluent-bit,app.kubernetes.io/instance=fluent-bit" -o jsonpath="{.items[0].metadata.name}")
kubectl --namespace logging port-forward $POD_NAME 2020:2020
curl http://127.0.0.1:2020
```
## Kibana
```

```

