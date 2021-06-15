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
#printf "I ${RED}love${NC} Stack Overflow\n"

COLOR_RED='\033[0;31m'
COLOR_GREEN='\033[1;32m'
COLOR_BLUE='\033[0;34m'
COLOR_YELLOW='\033[1;33m'
NO_COLOR='\033[0m'

export DOCKER_CLIENT_TIMEOUT=120
export COMPOSE_HTTP_TIMEOUT=120

# EXECUTE MANUALLY
#  Install Mosh
# sudo apt-get update && sudo apt-get install -y mosh 
#  Put private key to file
#   Create "gitlab" user
# adduser gitlab
# sudo -u gitlab -s
# mkdir ~/.ssh
# echo "<GITLAB_USER_PUBLIC_KEY>" >> ~/.ssh/authorized_keys
#   Make sure the permissions and ownership of the files are correct.
# chmod -R go= ~/.ssh
# chown -R $USER:$USER ~/.ssh

# let the user access with a key
### ssh-keygen
### ssh-copy-id gitlab@10.10.10.1
# install docker, setup docker-compose
### curl -fsSL https://get.docker.com -o get-docker.sh
### sudo sh get-docker.sh
### sudo usermod -aG docker gitlab
### systemctl start docker
# install compose
### sudo curl -L "https://github.com/docker/compose/releases/download/1.25.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
### sudo chmod +x /usr/local/bin/docker-compose
# allow multiple sessions (while deployment here will be lots of non blocking operations)
### sudo vi /etc/ssh/sshd_config 
### - MaxSessions 128
### sudo systemctl restart sshd

# Insert params to up.sh
# mkdir /droplet && mkdir /droplet/up && cd /droplet/up && wget https://raw.githubusercontent.com/train-to-cupertino/droplet-tools/main/scripts/collector/up.sh && chmod +x up.sh && ./up.sh <PARAMS>

# ------------------ START ------------------

# Assign variables
SPACE_KEY=$1
SPACE_SECRET=$2
SPACE_NAME=$3 # some-space
SPACE_ZONE=$4 # fra1 for example
SPACE_HOST=$5 # fra1.digitaloceanspaces.com for example
GPG_PASS=$6
PROJECT_NAME='wmtw-collector'
SSH_REPO_PRIVATE_KEY=$7
ENV_TYPE=$8
DB_DUMP_FILENAME=$9
NEO_DUMP_FILENAME=${10}
APP_IMAGE_FILE=${11}


# Clone repo
mkdir ~/.ssh/$PROJECT_NAME
echo -ne $SSH_REPO_PRIVATE_KEY > ~/.ssh/$PROJECT_NAME/private_key
chmod 600 ~/.ssh/$PROJECT_NAME/private_key
echo "Host $PROJECT_NAME" >> ~/.ssh/config
echo "HostName github.com" >> ~/.ssh/config
echo "User git" >> ~/.ssh/config
echo "IdentityFile ~/.ssh/$PROJECT_NAME/private_key" >> ~/.ssh/config
#echo "UseKeychain yes" >> ~/.ssh/config
echo "AddKeysToAgent yes" >> ~/.ssh/config
echo "" >> ~/.ssh/config
eval `ssh-agent -s`
ssh-add -k ~/.ssh/$PROJECT_NAME/private_key
mkdir /app && cd /app
git clone git@$PROJECT_NAME:train-to-cupertino/$PROJECT_NAME.git
printf "${COLOR_GREEN}Repo has been cloned${NO_COLOR}\n"

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

printf "${COLOR_GREEN}Docker has been installed${NO_COLOR}\n"

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

printf "${COLOR_GREEN}Docker-compose has been installed${NO_COLOR}\n"

# Create network
docker network create collector

printf "${COLOR_GREEN}Docker network 'collector' has been created${NO_COLOR}\n"

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

printf "${COLOR_GREEN}s3fs has been installed${NO_COLOR}, space mounted to ${COLOR_YELLOW}/spaces/$SPACE_NAME ${NO_COLOR}\n"

# Install s3cmd
sudo apt-get install -y s3cmd
# Settings
wget https://raw.githubusercontent.com/train-to-cupertino/droplet-tools/main/cfg/.s3cfg -O ~/.s3cfg
# Additional private settings
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

printf "${COLOR_GREEN}s3cmd has been installed${NO_COLOR}\n"

# To test S3
# mkdir /test-s3 && cd /test-s3 && s3cmd get s3://wmtw-shard-test-space-1/private/secret.txt && cat secret.txt 

# Get app docker image
mkdir /data
mkdir /data/docker_images
cd /data/docker_images
chmod 777 /data/docker_images
s3cmd get s3://wmtw-shard-test-space-1/private/docker-images/shard/app/$APP_IMAGE_FILE
docker load -i $APP_IMAGE_FILE

cd /app/$PROJECT_NAME
git checkout develop

# Deploy MySQL data
# Create MySQL data folder
mkdir /data/mysql
cd /app/$PROJECT_NAME/envs/$ENV_TYPE
# Up DB container
docker-compose up -d db

# Download dump
docker-compose exec db sh -c "mkdir /var/lib/mysql/dumps"
cd /data/mysql/dumps
s3cmd get s3://wmtw-shard-test-space-1/private/mysql/dumps/$DB_DUMP_FILENAME

# Create DB and load dump
cd /app/$PROJECT_NAME/envs/$ENV_TYPE
MYSQL_ROOT_PASSWORD=$(docker-compose exec db bash -c "printenv MYSQL_ROOT_PASSWORD")
MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD::-1}
MYSQL_DATABASE=$(docker-compose exec db bash -c "printenv MYSQL_DATABASE")
MYSQL_DATABASE=${MYSQL_DATABASE::-1}
#docker-compose exec db sh -c "mysql -uroot -p$MYSQL_ROOT_PASSWORD -e 'CREATE SCHEMA $MYSQL_DATABASE DEFAULT CHARACTER SET utf8;'" # DB creates automatically
printf "Load MySQL dump...\n"
 # ! ! ! UNCOMMENT ! ! ! 
docker-compose exec db sh -c "cd /var/lib/mysql/dumps && gunzip -c $DB_DUMP_FILENAME | mysql -uroot -p$MYSQL_ROOT_PASSWORD $MYSQL_DATABASE"

# Up app container
#docker-compose up -d app
# Up all one more time
#docker-compose up -d

# Assets and runtime folders
#docker-compose exec app bash -c "mkdir /app/backend/runtime"
#docker-compose exec app bash -c "chmod -R 777 /app/backend/runtime"
#docker-compose exec app bash -c "mkdir /app/backend/web/assets"
#docker-compose exec app bash -c "chmod -R 777 /app/backend/web/assets"

#docker-compose exec app bash -c "mkdir /app/storage/runtime"
#docker-compose exec app bash -c "chmod -R 777 /app/storage/runtime"
#docker-compose exec app bash -c "mkdir /app/storage/web/assets"
#docker-compose exec app bash -c "chmod -R 777 /app/storage/web/assets"
#docker-compose exec app bash -c "chmod -R 777 /app/storage/web/source"

#docker-compose exec app bash -c "mkdir /app/common/runtime"
#docker-compose exec app bash -c "chmod -R 777 /app/common/runtime"
