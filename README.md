# K8s on Ubuntu 22.04

Stack Setup:
- Ubuntu 22.04 Server
- Kubeadm for K8s setup
- Calico for CNI
- CRI-O for Container Runtime

## Steps to set up K8s on Ubuntu Server 22.04

- Get ISO for Ubuntu Server 22.04 or Desktop 
- If you get the desktop you will need to run the following command:
```
sudo install apt ubuntu-server -y
```
- Update Host file to contain IP Addresses for all machines in cluster and set each machines hostname.

## Install CRIO-O

```
sudo apt install apt-transport-https ca-certificates curl gnupg2 software-properties-common -y

export OS=xUbuntu_22.04
export CRIO_VERSION=1.24

vi .bashrc or .zshrc 
```

Add the following lines to the bottom of the file

```
export OS=xUbuntu_22.04
export CRIO_VERSION=1.24
```

Press th Esc key

```
:wq
```

In the console, source the cri-o runtime to download necessary libraries

```
echo "deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/ /"| sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
echo "deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$CRIO_VERSION/$OS/ /"|sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable:cri-o:$CRIO_VERSION.list

curl -L https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable:cri-o:$CRIO_VERSION/$OS/Release.key | sudo apt-key add -
curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/Release.key | sudo apt-key add -

sudo apt update

sudo apt install cri-o cri-o-runc -y

sudo systemctl start crio
sudo systemctl enable crio

sudo systemctl status crio

sudo apt install containernetworking-plugins -y
```

Add the configuration file for crio
```
sudo nano /etc/crio/crio.conf
- update the following lines in the file, uncomment and update.
--network_dir = "/etc/cni/net.d"
--plugin_dirs = [ "/opt/cni/bin", "/usr/lib/cni",]
```


Update Service and download remaining tools for cri-o
```
sudo systemctl restart crio

sudo apt install -y cri-tools

sudo crictl --runtime-endpoint unix:///var/run/crio/crio.sock version

sudo crictl info

sudo su -

crictl completion > /etc/bash_completion.d/crictl

source ~/.bashrc

exit

crictl
```

## Open Ports and turn off swap

### Control plane
Protocol	Direction	Port Range	Purpose	Used By
TCP	Inbound	6443	Kubernetes API server	All
TCP	Inbound	2379-2380	etcd server client API	kube-apiserver, etcd
TCP	Inbound	10250	Kubelet API	Self, Control plane
TCP	Inbound	10259	kube-scheduler	Self
TCP	Inbound	10257	kube-controller-manager	Self


### Worker node(s)
Protocol	Direction	Port Range	Purpose	Used By
TCP	Inbound	10250	Kubelet API	Self, Control plane
TCP	Inbound	30000-32767	NodePort Services†	All

## Turn off swap

```
swapoff -a

vi /etc/fstab
```

- Update the line referring to swap by commenting it out with a pound sign.  It is usually the last line.
- Press th Esc key

```
:wq
```



## Install libraries and k8s

```
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

```

Add sysctl params required by setup, params persist across reboot


```
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
```

Apply sysctl params without reboot

```
sudo sysctl --system
sudo apt-get update
```

Get K8s Libraries

```
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
```

FYI the service kubelet will keep erroring out until you either initialize the cluster and install the CNI or add it to the cluster.


## If Necessary:
- Configuring a cgroup driver
- Both the container runtime and the kubelet have a property called "cgroup driver", which is important for the management of cgroups on Linux machines.


## Only do on the control plane.

Start Up Control Plane

```
sudo kubeadm config images pull
sudo kubeadm init --pod-network-cidr=192.168.0.0/16

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

```

## Install CNI (Calico)

Deploy Network Operator and resources
```
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/tigera-operator.yaml

curl https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/custom-resources.yaml -O
```

### Update CIDR to match pod-network-cidr value above from starting cluster
```

kubectl create -f custom-resources.yaml

```





## Get Join token for workers

```

kubeadm token create --print-join-command

```

