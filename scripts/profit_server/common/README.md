### USE CASES ###

#### Run script by URL ####
```
source <(curl -s http://some.domain/path/to/script.sh)
```

#### Install Docker ####
```
source <(curl -s https://raw.githubusercontent.com/train-to-cupertino/droplet-tools/main/scripts/profit_server/common/install-docker.sh)
```
#### Install Docker-Compose ####
```
source <(curl -s https://raw.githubusercontent.com/train-to-cupertino/droplet-tools/main/scripts/profit_server/common/install-docker-compose-new.sh)
```
#### Add current user to "docker" group (make possible to run "docker ..." commands without sudo) ####
```
source <(curl -s https://raw.githubusercontent.com/train-to-cupertino/droplet-tools/main/scripts/profit_server/common/add-current-user-to-docker-group.sh)
```
