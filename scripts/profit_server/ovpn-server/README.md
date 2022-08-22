* Install Mosh:
```
sudo apt-get update && sudo apt-get install -y mosh
```

* Fix Mosh locale error (if needed)
```
apt-get update
apt-get install -y locales
locale-gen "ru_RU.UTF-8"
update-locale LC_ALL="ru_RU.UTF-8"
```

* Reconnect using Mosh

* Install git:
```
sudo apt-get install -y git
```

* Clone project: 
```
git clone https://github.com/train-to-cupertino/droplet-tools.git
```

Run scripts:
* Run "Install and configure dockerized OpenVPN server" script. For example:
```
chmod +x ./droplet-tools/scripts/profit_server/ovpn-server/install-ovpn-server.sh && ./droplet-tools/scripts/profit_server/ovpn-server/install-ovpn-server.sh 3000 myownvpn ovpndata
```

* Run "Add OpenVPN user" script: scripts/profit_server/ovpn-server/add-ovpn-user.sh. For example:
```
chmod +x ./droplet-tools/scripts/profit_server/ovpn-server/add-ovpn-user.sh && ./droplet-tools/scripts/profit_server/ovpn-server/add-ovpn-user.sh myownvpn ovpndata user1
```
