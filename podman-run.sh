podman volume create httpd-data
podman run -p 2221:2221 -p 8089:8089 \
    -e SSH_PORT=2221 \
    -e HTTP_PORT=8089 \
    -e AUTHORIZED_KEYS="ssh-ed25519 AAAACVNzaC1lZDI1NTE5AAAAIGxdiqataU6wsDsgLMRlFCqPFaJfO0GxwUTthOOmAHqt" \
    -v httpd-data:/data \
    docker.io/martinhillford/simple-content-server