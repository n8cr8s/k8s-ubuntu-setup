# Worker Node Services

## Startup K8s Service

1. Create a service unit file for your script. For example, create a file called myscript.service in the /etc/systemd/system/ directory:
```
sudo nano /etc/systemd/system/k8sstartup.service
```

2. Add the following content to the file:
```
[Unit]
Description=My Script
After=network.target
[Service]
ExecStart=/etc/init.d/k8sstartup
[Install]
WantedBy=default.target
```

3. Create file in etc/init.d/k8sstartup
```
sudo vi /etc/init.d/k8sstartup
```
Add Contents Below
```
#!/bin/bash
### BEGIN INIT INFO
# Provides:          myscript
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: My  Script
# Description:       Execute my  script at startup
### END INIT INFO
# Change to the directory where your  script is located
cd /path/to/your/script_directory
# Execute your script
token join cmd
```

4. Reload the systemd daemon to load the new service unit file:
```
sudo systemctl daemon-reload
```
5. Enable the service to start at boot:
```
sudo systemctl enable k8sstartup.service
```
6. Start the service:
```
sudo systemctl start k8sstartup.service
```


## Shutdown K8s Service

1. Create a service unit file for your script. For example, create a file called k8sshutdown.service in the /etc/systemd/system/ directory:

sudo nano /etc/systemd/system/k8sshutdown.service
2. Add the following content to the file:

[Unit]
Description=Run mycommand at shutdown
Requires=network.target
DefaultDependencies=no
Before=shutdown.target reboot.target

[Service]
Type=oneshot
RemainAfterExit=true
ExecStart=/bin/true
ExecStop=/etc/init.d/k8sshutdown

[Install]
WantedBy=multi-user.target


3.Replace /etc/init.d/k8sshutdown and Save the file and exit the text editor.
```
#!/bin/bash
### BEGIN INIT INFO
# Provides:          haltusbpower
# Required-Start:    $all
# Required-Stop:
# Default-Start:     2 3 4 5
# Default-Stop:
# Short-Description: Halts USB power...
### END INIT INFO

sudo kubeadm reset -y

```

4. Reload the systemd daemon to load the new service unit file:
```
sudo systemctl daemon-reload
```
5. Enable the service to start at boot:
```
sudo systemctl enable k8sshutdown.service
```
6. Start the service:
```
sudo systemctl start k8sshutdown.service
```