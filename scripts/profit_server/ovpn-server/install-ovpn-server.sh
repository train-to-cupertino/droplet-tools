# Define variables
SERVER_ADDRES=$(wget -q -O - eth0.me) # We get IP address of server using "eth0.me" service
SERVER_PORT=$1 # Server port. For example, 3000
DOCKER_IMAGE_NAME=$2 # Docker image name, for example: myownvpn
VPN_DATA_FOLDER=$3 # VPN data folder name, for example: ovpndata

# Install Docker
./../common/install-docker.sh # Clonning "Dockerized OpenVPN server" repository  
git clone https://github.com/kylemanna/docker-openvpn.git
cd docker-openvpn/
# Build Docker image
docker build -t $DOCKER_IMAGE_NAME . 
cd ..
mkdir $VPN_DATA_FOLDER && touch $VPN_DATA_FOLDER/vars
# Run Docker container
docker run -v $PWD/$VPN_DATA_FOLDER:/etc/openvpn --rm $DOCKER_IMAGE_NAME ovpn_genconfig -u udp://$SERVER_ADDRESS:SERVER_PORT 
# Init PKI
docker run -v $PWD/$VPN_DATA_FOLDER:/etc/openvpn --rm -it $DOCKER_IMAGE_NAME ovpn_initpki # input needed data
# Run VPN server
docker run -v $PWD/$VPN_DATA_FOLDER:/etc/openvpn -d -p $SERVER_PORT:1194/udp --cap-add=NET_ADMIN $DOCKER_IMAGE_NAME

echo '\n\nInstallation completed!\nRun add-ovpn-user.sh script to add OpenVPN user and get its config file'
