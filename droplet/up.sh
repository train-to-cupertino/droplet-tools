###################################################
# SCRIPT FOR EXECUTING AFTER DROPLET HAS BEEN UPPED
###################################################

#Black        0;30     Dark Gray     1;30
#Red          0;31     Light Red     1;31
#Green        0;32     Light Green   1;32
#Brown/Orange 0;33     Yellow        1;33
#Blue         0;34     Light Blue    1;34
#Purple       0;35     Light Purple  1;35
#Cyan         0;36     Light Cyan    1;36
#Light Gray   0;37     White         1;37
#RED='\033[0;31m'
#NC='\033[0m' # No Color
#printf "I ${RED}love${NC} Stack Overflow\n"

# EXECUTE MANUALLY
# sudo apt-get update && sudo apt-get install -y mosh && mkdir /droplet && mkdir /droplet/up && cd /droplet/up && wget https://raw.githubusercontent.com/train-to-cupertino/droplet-up-script/main/droplet/up.sh && chmod +x up.sh && ./up.sh

# Assign variables
SPACE_KEY=$1
SPACE_SECRET=$2
SPACE_NAME=$3 #
SPACE_ZONE=$4 # fra1 for example
SPACE_HOST=$5 # fra1.digitaloceanspaces.com for example
GPG_PASS=$6

# Install Docker

sudo apt-get update
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
# todo:  auto confirm
# TODO: Check fingerprint
# sudo apt-key fingerprint 0EBFCD88 | grep "9DC8 5822 9FC7 DD38 854A  E2D8 8D81 803C 0EBF CD88"
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io
# sudo groupadd docker                        #  TO RUN DOCKER
# sudo usermod -aG docker $USER    #   WITHOUT SUDO

# docker system prune -f # Delete unused containers

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

# Create network
docker network create shard

#sudo apt-get install -y py-pip python-dev libffi-dev openssl-dev gcc libc-dev make

# Install s3fs
sudo apt-get update
sudo apt-get install -y s3fs
echo $SPACE_KEY:$SPACE_SECRET > ~/.passwd-s3fs
chmod 600 ~/.passwd-s3fs
sudo mkdir /spaces
sudo mkdir /spaces/$SPACE_NAME
echo user_allow_other > /etc/fuse.conf
chmod 644 /etc/fuse.conf
sudo s3fs $SPACE_NAME /spaces/$SPACE_NAME -o url=https://$SPACE_ZONE.digitaloceanspaces.com -o use_cache=/tmp -o allow_other -o use_path_request_style -o uid=$(id -u) -o gid=$(id -g)

# TODO: Install s3cmd
sudo apt-get install -y s3cmd
# TODO: s3cmd --configure
# TODO: PUT https://raw.githubusercontent.com/train-to-cupertino/droplet-up-script/main/droplet/.s3cfg 
# TODO: to /home/$(whoami)/.s3cfg
# Additional settings
wget https://raw.githubusercontent.com/train-to-cupertino/droplet-up-script/main/droplet/.s3cfg 
cp ./.s3cfg ~/.s3cfg
echo "access_key = $SPACE_KEY" >> ~/.s3cfg
echo "secret_key = $SPACE_SECRET" >> ~/.s3cfg
echo "host_base = $SPACE_HOST" >> ~/.s3cfg
echo "host_bucket = %(bucket)s.$SPACE_HOST" >> ~/.s3cfg
echo "gpg_passphrase = $GPG_PASS" >> ~/.s3cfg
echo "content_disposition = " >> ~/.s3cfg
echo "content_type = " >> ~/.s3cfg
echo "upload_id = " >> ~/.s3cfg
echo "throttle_max = 100" >> ~/.s3cfg
chmod 600 ~/.s3cfg

# To test S3
# mkdir /test-s3 && cd /test-s3 && s3cmd get s3://wmtw-shard-test-space-1/private/secret.txt && cat secret.txt
# 
