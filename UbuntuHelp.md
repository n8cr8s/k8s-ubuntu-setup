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
