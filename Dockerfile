FROM debian:bookworm-slim

# Base
RUN apt-get update && apt-get install -y --no-install-recommends \
    openssh-server nginx supervisor ca-certificates gettext \
    libnginx-mod-http-brotli-filter libnginx-mod-http-brotli-static \
  && rm -rf /var/lib/apt/lists/*

# SSH host keys
RUN mkdir -p /var/run/sshd && ssh-keygen -A

# Create sftp-only group and a sample user (change as needed)
# - shell set to nologin since we'll ForceCommand internal-sftp
RUN groupadd -r sftponly \
 && useradd -m -d /home/sftpuser -s /usr/sbin/nologin -G sftponly sftpuser \
 && passwd -d sftpuser \
 && usermod -U sftpuser

# SSH authorized_keys path + sane perms
RUN mkdir -p /home/sftpuser/.ssh \
 && chown -R sftpuser:sftpuser /home/sftpuser/.ssh \
 && chmod 700 /home/sftpuser/.ssh

# Chroot target + a writable subdir for users
RUN mkdir -p /data/www \
 && chown root:root /data && chmod 755 /data \
 && chown sftpuser:sftponly /data/www && chmod 755 /data/www

# OpenSSH config (SFTP-only + chroot to /data)
COPY sshd_config /etc/sshd/sshd_config_template
COPY nginx.conf /etc/nginx/nginx.template

# Supervisor to run both daemons in one container
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Helpful volumes so keys/data persist across rebuilds
VOLUME ["/etc/ssh", "/data", "/home/sftpuser/.ssh"]

# Setup the port to listen too 
ENV HTTP_PORT 8080
ENV SSH_PORT 2222
EXPOSE 2222 8080

# Deal with an  
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
CMD ["sh", "-c", "/entrypoint.sh"]