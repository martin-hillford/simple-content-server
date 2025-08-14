# 1) Prepare keys for the sftp user (on your host)
mkdir -p ./keys
ssh-keygen -t ed25519 -f ./keys/sftpuser_ed25519 -N ""

# 2) Put the public key into authorized_keys that will be mounted
mkdir -p .
cat ./keys/sftpuser_ed25519.pub > ./authorized_keys

podman volume create data
podman volume create sshkeys
podman run -p 2221:2221 -p 8089:8089 \
    -e SSH_PORT=2221 \
    -e HTTP_PORT=8089 \
    -v data:/data \
    -v sshkeys:/etc/ssh \
    -v ./authorized_keys:/home/sftpuser/.ssh/authorized_keys:ro \
    content-server