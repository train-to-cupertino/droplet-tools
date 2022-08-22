# Define variables
DOCKER_IMAGE_NAME=$1 # Docker image name
VPN_DATA_FOLDER=$2 # VPN data folder name
USERNAME=$3 # OVPN username

# Add OpenVPN user
docker run -v $PWD/$VPN_DATA_FOLDER:/etc/openvpn --rm -it $DOCKER_IMAGE_NAME easyrsa build-client-full $USERNAME nopass
# Save OpenVPN user config to file
docker run -v $PWD/$VPN_DATA_FOLDER:/etc/openvpn --rm $DOCKER_IMAGE_NAME ovpn_getclient $USERNAME > $VPN_DATA_FOLDER/users/$USERNAME.ovpn
echo 'User $USERNAME was added\n. Save it config file $USERNAME.ovpn using command:\n scp <SSH_USER>@<SERVER_ADDRESS>:/root/$VPN_DATA_FOLDER/users/$USERNAME.ovpn ~'
