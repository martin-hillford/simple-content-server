docker volume create httpd-data
docker volume create httpd-sshkeys
docker run -p 2221:2221 -p 8081:8081 \
    -e SSH_PORT=2221 \
    -e HTTP_PORT=8081 \
    -v httpd-data:/data \
    -v httpd-sshkeys:/etc/ssh \
    -e AUTHORIZED_KEYS="ssh-ed25519 AAAACVNzaC1lZDI1NTE5AAAAIGxdiqataU6wsDsgLMRlFCqPFaJfO0GxwUTthOOmAHqt" \
    docker.io/martinhillford/simple-content-server