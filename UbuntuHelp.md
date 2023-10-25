# Ubuntu Helper Commands 

## List Services running

```
systemctl list-units --type service
```

## List of packages

```
apt list --installed
```

Note: Lines with "all", in the command above are root packages.  Lines with "armhf" are dependencies.


## List Ports

```
sudo netstat -tulpn 
```

## List Firewall Ports

```
sudo iptables -L
```

## SSH Service

Remove Root access from ssh and prevent password based login

```
sudo vi /etc/ssh/sshd_config
# Update Password Login
PasswordAuthentication no
# Update PermitRootLogin
PermitRootLogin no
```
