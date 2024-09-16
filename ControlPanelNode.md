# Control Panel Node


## Startup K8s Service

1. Create a service unit file for your script. For example, create a file called myscript.service in the /etc/systemd/system/ directory:
```
sudo vi /etc/systemd/system/k8sstartup.service
```

2. Add the following content to the file:
```
[Unit]
Description=Run mycommand at startup
DefaultDependencies=no
After=multi-user.target

[Service]
ExecStart=/etc/init.d/k8sstartup
Restart=always

[Install]
WantedBy=multi-user.target
Alias=k8sstartup.service
```
Escape :wq, then chmod +x /etc/init.d/k8sstartup.service

3. Create file in etc/init.d/k8sstartup
```
sudo vi /etc/init.d/k8sstartup
```
Add Contents Below
```
#!/bin/bash
### BEGIN INIT INFO
# Provides:          k8sstartup
# Required-Start:    $all
# Required-Stop:
# Default-Start:     2 3 4 5
# Default-Stop:
# Short-Description: Start k8s
### END INIT INFO
sleep 30
kubeadm token create --print-join-command --ttl 6h >  /misc/k8snodes/k8snodes/k8s_token_"$(date +'%Y_%m_%d_%I_%M_%p')".txt

```
Escape :wq, 
```
chmod +x k8sstartup
chown root:root k8sstartup
```

4. Reload the systemd daemon to load the new service unit file:
```
sudo systemctl daemon-reload
```

5. Start the service:
```
sudo systemctl start k8sstartup.service
```