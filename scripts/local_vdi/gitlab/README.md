# Gitlab in docker
1. Run `docker compose up -d` in the root folder to run Gitlab
2. Run `docker compose exec -it gitlab_app gitlab-rake "gitlab:password:reset[root]"` to change root password
3. Go to web interface and login as root
4. Command to register runner, execute in the runner container: `sudo gitlab-runner register --url http://<GITLAB_IP_OR_URL>/ --registration-token $REGISTRATION_TOKEN`. Token you must get here: http://<GITLAB_IP_OR_URL>/<PATH/TO/PROJECT>/-/settings/ci_cd at the "Runners" section
5. Edit "runners" section in the [runner's config file](runner/srv/gitlab-runner/config/config.toml) to be the same as an example in the same file
