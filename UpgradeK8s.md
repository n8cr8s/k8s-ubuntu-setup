# Upgrade K8s

## Control Plane Primary Node

### RHEL/CentOs
```
yum install -y kubeadm-1.xx.x-0 --disableexcludes=kubernetes
```
### Ubuntu/Debian
```
# Replace xx.x with version, example, 1.22.0-00
apt-mark unhold kubeadm && \
apt-get update && apt-get install -y \
kubeadm=1.xx.x-00 && \
apt-mark hold kubeadm
```

### Validate Version and Test Upgrade
```
kubeadm version
kubeadm upgrade plan
```

### Apply update
```
sudo kubeadm upgrade apply v1.xx.x
```

## Additional Control Plane Nodes and Worker Nodes
- First update the other control plane nodes
- Second update the worker nodes
- Every node in cluster must be updated
- Additional Control Plane nodes can be updated one at a time after the primary node is updated.
- Worker nodes can be done in parallel with each other.

From the node
```
sudo kubeadm upgrade node
```

From primary control plane
```
kubectl drain <node> --ignore-daemonset
```

### RHEL/CentOs
```
yum install -y kubelet-1.xx.x-0 kubectl-1.xx.x-0  --disableexcludes=kubernetes
```

### Ubuntu/Debian
```
# Replace xx.x with version, example, 1.22.0-00
apt-mark unhold kubelet kubectl && \
apt-get update && apt-get install -y \
kubelet=1.xx.x-00 kubectl=1.xx.x-00 && \
apt-mark hold kubelet kubectl
```

### System Daemon Reload and Restart Kubelet
From node
```
sudo systemctl daemon-reload
sudo systemctl restart kubelet
```
From Primary Node
```
kubectl uncordon <node>
```


