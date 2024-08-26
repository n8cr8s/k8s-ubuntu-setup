# K8s on Ubuntu 22.04

Stack Setup:
- Ubuntu 22.04 Server
- Kubeadm for K8s setup
- Cilium for CNI
- Containerd for Container Runtime

## Steps to set up Ubuntu Server 22.04

- Get ISO for Ubuntu Server 22.04 or Desktop 
- If you get the desktop you will need to run the following command:
```
sudo apt install ubuntu-server -y

sudo apt install openssh-server -y
```

Update the sudoers file in Workers Only; create a new file for permissions don't edit the original.
```
sudo visudo -f /etc/sudoers.d/<username>
```

Add the following line to allow access to add to cluster via kubeadm without a password when using a key file.
```
<username> ALL=NOPASSWD:/usr/bin/kubeadm
```

Ctrl+X to exit, Y for save; validate format
```
sudo visudo -c
```

## Install and update needed libraries

```
sudo apt update

sudo apt -y full-upgrade

sudo apt install apt-transport-https ca-certificates curl gpg gnupg2 software-properties-common -y

```

### Enable time-sync with NTP server
```
sudo apt install systemd-timesyncd

sudo timedatectl set-ntp true
```


## Turn off swap

```
sudo swapoff -a

sudo vi /etc/fstab
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
# Update to your version of k8s, this is set to 1.30
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt update
sudo apt install -y kubelet kubeadm kubectl
sudo apt-mark hold kubeadm kubelet kubectl
```

FYI the service kubelet will keep erroring out until you either initialize the cluster and install the CNI or add it to the cluster.

## Install Containerd
Download most recent version
```
wget https://github.com/containerd/containerd/releases/download/v1.6.8/containerd-1.6.8-linux-amd64.tar.gz
sudo tar Cxzvf /usr/local containerd-1.6.8-linux-amd64.tar.gz
```

Get most recent  version of runc
```
wget https://github.com/opencontainers/runc/releases/download/v1.1.3/runc.amd64
sudo install -m 755 runc.amd64 /usr/local/sbin/runc
```

Get CNI-Plugins most recent version extract and place
```
wget https://github.com/containernetworking/plugins/releases/download/v1.1.1/cni-plugins-linux-amd64-v1.1.1.tgz

mkdir -p /opt/cni/bin
sudo tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v1.1.1.tgz
```

Create containerd dir and deploy
```
sudo mkdir -p /etc/containerd/
containerd config default | sudo tee /etc/containerd/config.toml
```

Enable default SystemdCgroup
```
sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml
```

Download and place containerd service
```
sudo curl -L https://raw.githubusercontent.com/containerd/containerd/main/containerd.service -o /etc/systemd/system/containerd.service

sudo systemctl daemon-reload

sudo systemctl start containerd
sudo systemctl enable containerd
```

- Setup crictl for inspecting containers 
Once the installation is completed, re-run the sudo crictl ps command. You may encounter output with errors and warnings. To address these issues, we need to add configurations for crictl. Additionally, you can customize the debug output using this config file

Create crictl.yaml file in /etc/
```
sudo vim /etc/crictl.yaml
```
Paste below content, save and exit
```
runtime-endpoint: unix:///run/containerd/containerd.sock
image-endpoint: unix:///run/containerd/containerd.sock
timeout: 2
debug: true # <- if you don't want to see debug info you can set this to false
pull-image-on-create: false
```
Run the sudo crictl ps again,and you shouldn’t encounter any errors or warnings
```
sudo sysctl --system
sudo crictl ps
```

## If Necessary:
- Configuring a cgroup driver
- Both the container runtime and the kubelet have a property called "cgroup driver", which is important for the management of cgroups on Linux machines.

## Start Kubelet service
```
sudo systemctl start kubelet
sudo systemctl enable kubelet
```

## Only do on the control plane.

Start Up Control Plane

```
sudo crictl images

sudo kubeadm config images pull --cri-socket unix:///var/run/containerd/containerd.sock

sudo crictl images

sudo kubeadm init --pod-network-cidr=192.168.0.0/16 --cri-socket unix:///var/run/containerd/containerd.sock --v=5

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

```

## Install CNI (Cilium)

Install Linux Client
```
CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
CLI_ARCH=amd64
if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi
curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
sha256sum --check cilium-linux-${CLI_ARCH}.tar.gz.sha256sum
sudo tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin
rm cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
```

Install Mac Client
```
CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
CLI_ARCH=amd64
if [ "$(uname -m)" = "arm64" ]; then CLI_ARCH=arm64; fi
curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-darwin-${CLI_ARCH}.tar.gz{,.sha256sum}
shasum -a 256 -c cilium-darwin-${CLI_ARCH}.tar.gz.sha256sum
sudo tar xzvfC cilium-darwin-${CLI_ARCH}.tar.gz /usr/local/bin
rm cilium-darwin-${CLI_ARCH}.tar.gz{,.sha256sum}
```

Validate Version
```
cilium version --client
```

Install Cilium
```
cilium install --version 1.14.4
```

Validate Install Status
```
cilium status --wait
```

Test Connectivity
```
cilium connectivity test
```

Update Firewall with IP for Cilium Cluster

## Get Join token for workers

```

kubeadm token create --print-join-command

```

## On worker node
Paste join command

```
# Substitute in values controller-plane-node-id, token.00000 and sha256:01234567890 with values from command above, 
# or just paste the output from the command with sudo in front of it

sudo kubeadm join controller-plane-node-ip:6443 --token token.000000 --discovery-token-ca-cert-hash sha256:01234567890

# Create directory for local-storage
sudo mkdir /mnt/data
sudo chmod -R 755 /mnt/data
```

# Locking down the system
After Finishing other steps do the following on all nodes
## Open Ports and turn off swap

Get the Cilium Octet and add to firewall allow list; the value is under cluster-pool-ipv4-cidr
```
kubectl -n kube-system get configmap cilium-config -o yaml

kubectl get nodes
```

I recommend turning on the firewall with the following command and add all computers to the allowed list.

```
sudo ufw allow from <cluster-pool-ipv4-cidr>
sudo ufw enable
```
[Official Ubuntu ufw manual](https://manpages.ubuntu.com/manpages/jammy/en/man8/ufw.8.html)
[Digital Ocean Tutorial on Firewall Setup](https://www.digitalocean.com/community/tutorials/how-to-set-up-a-firewall-with-ufw-on-ubuntu-22-04)


### Control plane

| Protocol | Direction | Port Range | Purpose | Used By |
| --- | --- | --- | --- | --- |
| TCP | Inbound | 6443 | Kubernetes API server | All |
| TCP | Inbound | 2379-2380 | etcd server client API | kube-apiserver, etcd |
| TCP | Inbound | 10250 | Kubelet API | Self, Control plane | 
| TCP | Inbound | 10259 | kube-scheduler | Self | 
| TCP | Inbound | 10257 | kube-controller-manager | Self | 




### Worker node(s)

 | Protocol | Direction | Port Range | Purpose | Used By |
 | --- | --- | --- | --- | --- |
 | TCP | Inbound | 10250 | Kubelet API | Self, Control plane | 
 | TCP | Inbound | 30000-32767 | NodePort Services† | All | 


- Update Host file to contain IP Addresses for all machines in cluster and set each machines hostname.
```
sudo vi /etc/hosts
```

- Generate ssh-key to ssh in from host to login to each server without using password; I recommend naming the file something other than id_rsa

Version One

On the new node, open sshd_config and remove password access; uncomment and change answer to yes to add new key to node
```
sudo vi /etc/ssh/sshd_config

PasswordAuthentication yes
```
Escape and then :wq to Quit and Save
Reload ssh  
```
sudo service ssh force-reload
```
Also get the ip address via ifconfig on the new node.  You will  need to install it.

On the Control Plane Node
```
# If you don't have one to use, generate a key, otherwise skip this step.
ssh-keygen

ssh-copy-id -i </path/to/public/key.pub> username@server-ip-address

# cmd to login: ssh -i </path/to/private_key> <user>@<host-ip-address>
```
Open sshd_config and remove password access; uncomment and change answer to no
```
sudo vi /etc/ssh/sshd_config

PasswordAuthentication no
```
Escape and then :wq to Quit and Save
Reload ssh

```
sudo service ssh force-reload
```
Version 2
```
# Alternate way by logging into server and then copying the file to it.

mkdir -p /home/user_name/.ssh && touch /home/user_name/.ssh/authorized_keys

# Put pub key contents in authorized_keys
vi /home/user_name/.ssh/authorized_keys

# Create file to prevent having to answer "yes" to ssh question about host authorization
cat <<EOF | sudo tee /home/<username>/.ssh/config
StrictHostKeyChecking accept-new
EOF

# Update Permissions
chmod 700 /home/user_name/.ssh && chmod 600 /home/user_name/.ssh/authorized_keys

chown -R username:username /home/username/.ssh
```
- Copy private key to deployment server for k8s nodes as well if needed.
