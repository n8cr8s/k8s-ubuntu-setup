# Upgrade K8s

## Control Plane Primary Node

### Ubuntu/Debian
```
sudo apt update
sudo apt install -y kubelet kubeadm kubectl
sudo apt-mark hold kubeadm kubelet kubectl
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

Install new version

### Ubuntu/Debian
```
sudo apt-mark unhold kubelet kubectl kubeadm
sudo apt update
sudo apt install -y kubelet kubeadm kubectl
sudo apt-mark hold kubeadm kubelet kubectl
```


From the node (Only additional Control Plane nodes)
```
sudo kubeadm upgrade node
```

From primary control plane
```
kubectl drain <node> --ignore-daemonset
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


