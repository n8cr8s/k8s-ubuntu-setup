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


## Additional Control Plane Nodes
From the node
```
sudo kubeadm upgrade node
```

From primary control plane
```
kubectl drain <node> --ignore-daemonset
```
