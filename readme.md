# Simple Content Server
This Docker container runs a simple content server, accessible via SSH for file uploads. Users log in through SSH with a chroot environment. NGINX serves files from the user's `/www` directory and supports gzip and Brotli compression. Pre-compressed files (with `.gz` or `.br` suffixes) are also supported.
By default, NGINX runs on port 8080 and SSH on port 2222, but these can be configured using the SSH_PORT and HTTP_PORT environment variables. Below is an example of how to start the container:


```bash
docker run -p 2222:2222 -p 8080:8080 \
    -e SSH_PORT=2221 \
    -e HTTP_PORT=8080 \
    -e AUTHORIZED_KEYS="ssh-ed25519 AAAACVNzaC1lZDI1NTE5AAAAIGxdiqataU6wsDsgLMRlFCqPFaJfO0GxwUTthOOmAHqt" \ 
    -v data:/data \
    docker.io/martinhillford/simple-content-server
```

To ensure data persistence, bind a volume to `/data`.

To get access to the sever inject the allowed public key(s) via the environment variable `AUTHORIZED_KEYS`.
this variable can take multiple keys if they are separated by |. It is now possible to login with the user 
`sftpuser` and the provided key.