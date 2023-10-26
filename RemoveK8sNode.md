# Remove K8s Nodes

```
# Mark Node as unschedulable
kubectl cordon <node_name>

# Drain pods from node
kubectl drain <node_name> --ignore-daemonsets

# Remove from cluster
kubectl delete node <node_name>
```
