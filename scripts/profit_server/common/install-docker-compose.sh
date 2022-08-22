#Install Docker Compose

sudo apt-get install -y py-pip
sudo apt-get install -y python-dev
sudo apt-get install -y libffi-dev
sudo apt-get install -y openssl-dev
sudo apt-get install -y gcc
sudo apt-get install -y libc-dev
sudo apt-get install -y make
sudo curl -L "https://github.com/docker/compose/releases/download/1.28.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

printf "Docker-compose has been installed\n"

