# Change password and "ftpdata" folder
docker rm ftp && docker run --detach --env FTP_PASS=SOMEPASS --env FTP_USER=user1 --name ftp --publish 20-21:20-21/tcp --publish 40000-40009:40000-40009/tcp --volume /ftpdata:/home/user1 garethflowers/ftp-server
# Use --restart always to prevent ftp server downtime
