COLOR_RED='\033[0;31m'
COLOR_GREEN='\033[1;32m'
COLOR_BLUE='\033[0;34m'
COLOR_YELLOW='\033[1;33m'
NO_COLOR='\033[0m'

# EXECUTE MANUALLY
# Install Mosh
# sudo apt-get update && sudo apt-get install -y mosh 
# Put private key to file
# Insert params to up.sh
# mkdir /droplet && mkdir /droplet/up && cd /droplet/up && wget https://raw.githubusercontent.com/train-to-cupertino/droplet-up-script/main/droplet/up.sh && chmod +x up.sh && ./up.sh <PARAMS>

# ------------------ START ------------------

# Assign variables
SPACE_KEY=$1
SPACE_SECRET=$2
SPACE_NAME=$3 # some-space
SPACE_ZONE=$4 # fra1 for example
SPACE_HOST=$5 # fra1.digitaloceanspaces.com for example
GPG_PASS=$6
PROJECT_NAME='wmtw-shard'
SSH_REPO_PRIVATE_KEY=$7
ENV_TYPE=$8
DB_DUMP_FILENAME=$9
NEO_DUMP_FILENAME=$10




cd /app/wmtw-shard
git checkout develop

# Deploy MySQL data
# Create MySQL data folder
mkdir /data && mkdir /data/mysql
cd /app/wmtw-shard/envs/$ENV_TYPE
# Up DB container
docker-compose up -d db

# Download dump
docker-compose exec db sh -c "mkdir /var/lib/mysql/dumps"
cd /data/mysql/dumps
s3cmd get s3://wmtw-shard-test-space-1/private/mysql/dumps/$DB_DUMP_FILENAME

MYSQL_USER=$(docker-compose exec db bash -c "printenv MYSQL_USER")
MYSQL_PASSWORD=$(docker-compose exec db bash -c "printenv MYSQL_PASSWORD")
MYSQL_DATABASE=$(docker-compose exec db bash -c "printenv MYSQL_DATABASE")

# Create DB and load dump
cd /app/wmtw-shard/envs/$ENV_TYPE
docker-compose exec db sh -c "mysql -u$MYSQL_USER -p$MYSQL_PASSWORD -e 'CREATE SCHEMA `$MYSQL_DATABASE` DEFAULT CHARACTER SET utf8;'"
printf "Load MySQL dump...\n"
docker-compose exec db sh -c "cd /var/lib/mysql/dumps && gunzip -c $DB_DUMP_FILENAME | mysql -u$MYSQL_USER -p$MYSQL_PASSWORD"


# Deploy Neo4j data
# Create Neo4j data folder
mkdir /data/neo
cd /app/wmtw-shard/envs/$ENV_TYPE
# Up Neo4j container
docker-compose up -d neo

# Download dump
docker-compose exec neo sh -c "mkdir /data/dumps"
cd /data/neo/data/dumps
s3cmd get s3://wmtw-shard-test-space-1/private/neo/dumps/$NEO_DUMP_FILENAME

NEO_DB_USERNAME=$(docker-compose exec db bash -c "printenv NEO_DB_USERNAME")
NEO_DB_PASSWORD=$(docker-compose exec db bash -c "printenv NEO_DB_PASSWORD")
NEO_DB_NAME=$(docker-compose exec db bash -c "printenv NEO_DB_NAME")

# Create DB
cd /app/wmtw-shard/envs/$ENV_TYPE
docker-compose exec neo sh -c "echo 'CREATE DATABASE $NEO_DB_NAME' | cypher-shell -u $NEO_DB_USERNAME -p $NEO_DB_PASSWORD"
# Restart Neo4j container
docker-compose stop neo
docker-compose up -d neo
# Load Neo4j dump
printf "Load Neo4j dump...\n"
docker-compose exec neo sh -c "neo4j-admin load --from=$NEO_DUMP_FILENAME --database=$NEO_DB_NAME --force"
