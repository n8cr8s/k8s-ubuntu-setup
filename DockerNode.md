# Setup for Docker Build Server (Ubuntu Server)

- Follow all steps for Worker Node setup excluding k8s libraries

# Setup for Docker

## Cleanup
```
sudo apt-get purge docker-ce docker-ce-cli containerd.io
```

```
sudo rm -rf /var/lib/docker
sudo rm -rf /var/lib/containerd
```

## Refresh apt
```
sudo apt update
```

Setup Repository
```
sudo apt-get install \
ca-certificates \
curl \
gnupg \
lsb-release
```

Add Docker official GPG key

```
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
```
Use the following command to set up the stable repository
```
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null


ls -al /etc/apt/sources.list.d | grep docker

```

## Docker Engine Install

Update registry, get the latest Docker engine files, and verify verision
```
apt update 

sudo apt-get install docker-ce docker-ce-cli containerd.io

apt-cache madison docker-ce
```

Determine which version you want to install based on the command above
The example shows the command using 5:20.10.5~3-0~ubuntu-focal

```
sudo apt-get install docker-ce=5:20.10.5~3-0~ubuntu-focal docker-ce-cli=5:20.10.5~3-0~ubuntu-focal containerd.io
```

Validate install
```
sudo docker run hello-world
```

## Post Install Steps

Verify Docker Service is enabled for startup

```
sudo systemctl list-unit-files --type=service | grep docker.service
```

Add user to docker group
```
sudo usermod -aG docker $USER

newgrp docker

docker run hello-world

```

## Configure Remote Connection 

Open the following docker.service file.
```
sudo systemctl edit docker.service
```

IMPORTANT: IT WILL NOT WORK UNLESS YOU COPY AND PASTE the following immediately after the header comments, OTHERWISE NO WORKY.

```
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd -H fd:// -H tcp://0.0.0.0:2376
```

Then enter, Ctrl+X, Y

Reload Daemon
```
sudo systemctl daemon-reload
```

Restart Docker Service
```
sudo systemctl restart docker.service
```

Verify Docker Service is open; the following command will return data.

```
sudo netstat -lntp | grep dockerd
```
tcp6    0   0   :::2376 :::*    LISTEN 21441/dockerd


## Update ufw for IP masquerading
Open the file.
```
vi /etc/default/ufw
```

Add then change the value below to ACCEPT.
```
DEFAULT_FORWARD_POLICY="ACCEPT"
```
Close the file.

Ctrl+: wq

```
vi /etc/ufw/sysctl.conf
```
Uncomment the following lines
```
net/ipv4/ip_forward=1
net/ipv6/conf/default/forwarding=1
```

```
vi /etc/ufw/before.rules
```

Add the following to the top of the file just after the header comments.

```
# nat Table rules
*nat
:POSTROUTING ACCEPT [0:0]

# Forward traffic from eth1 through eth0.
-A POSTROUTING -s 192.168.0.0/24 -o eth0 -j MASQUERADE

# don't delete the 'COMMIT' line or these nat table rules won't be processed
COMMIT
```

Restart ufw
```
sudo ufw disable && sudo ufw enable
```

After doing this everything is complete, add the following to the kubernetes yaml file.  An Example is below.
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: your-deployment
spec:
  # ... other deployment specs
  template:
    spec:
      containers:
      - name: your-container
        image: your-image
        env:
        - name: DOCKER_HOST
          value: "tcp://remote-docker-host:2376" # Unencrypted
```