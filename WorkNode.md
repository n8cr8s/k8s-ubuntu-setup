# Worker Node Services

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
Type=oneshot

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
export k8scmd=$(cat /misc/k8snodes/$(ls /misc/k8snodes/ -Art | tail -n 1))
sudo $k8scmd

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

## Shutdown K8s Service

1. Create a service unit file for your script. For example, create a file called k8sshutdown.service in the /etc/systemd/system/ directory:
```
sudo vi /etc/systemd/system/k8sshutdown.service
```
2. Add the following content to the file:
```
[Unit]
Description=Run mycommand at shutdown
DefaultDependencies=no
Before=shutdown.target

[Service]
Type=oneshot
ExecStart=/etc/init.d/k8sshutdown

[Install]
WantedBy=halt.target reboot.target shutdown.target
Alias=k8sshutdown.service
```
Escape :wq
```
chmod +x /etc/systemd/system/k8sshutdown.service
chown root:root /etc/systemd/system/k8sshutdown.service
```
3.Replace /etc/init.d/k8sshutdown and Save the file and exit the text editor.
```
#!/bin/bash
### BEGIN INIT INFO
# Provides:          k8sshutdown
# Required-Start:    $all
# Required-Stop:
# Default-Start:     2 3 4 5
# Default-Stop:
# Short-Description: Stop k8s
### END INIT INFO

sudo kubeadm reset --force || exit 1
exit 0

```
Escape :wq
4. Change permission and ownership and reload the systemd daemon to load the new service unit file:
```
chmod +x /etc/init.d/k8sshutdown
chown root:root /etc/init.d/k8sshutdown

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

## Set up MacOs with Virtual Box

Download correct version of Virtual Box for version of MacOS

https://www.virtualbox.org/

After Installing Virtual Box and Ubuntu
- Open up the Applications
- Open User and Groups
- For the desired user, Click Login Items
- Click on the + at the bottom, and select Application -> Other -> Automator.

In Automator
- Select Run a Shell Script.
- Shell: /bin/zsh
- Pass input: to stdin
- Add the following
```
pmset dispalysleepnow
/usr/local/bin/VBoxManage startvm <vmname>
```
- Save file as SaveVM
