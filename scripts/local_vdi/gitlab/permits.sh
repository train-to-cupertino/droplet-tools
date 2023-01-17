sudo chmod -R 777 ./export/
sudo chmod 600 ./export/containers/gitlab-config/ssh_host_ecdsa_key
sudo chmod 600 ./export/containers/gitlab-config/ssh_host_ed25519_key
sudo chmod 600 ./export/containers/gitlab-config/ssh_host_rsa_key
sudo docker compose exec -it gitlab_app update-permissions
