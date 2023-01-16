#docker exec -it gitlab_app update-permissions
sudo chmod -R 777 ~/gitlab/export/
sudo chmod 600 ~/gitlab/export/containers/gitlab-config/ssh_host_ecdsa_key
sudo chmod 600 ~/gitlab/export/containers/gitlab-config/ssh_host_ed25519_key
sudo chmod 600 ~/gitlab/export/containers/gitlab-config/ssh_host_rsa_key
docker compose exec -it gitlab_app update-permissions
