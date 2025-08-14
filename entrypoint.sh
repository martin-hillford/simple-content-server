 #!/usr/bin/env bash

# Persist SSH config/keys in the single /data volume
SSH_DIR="${SSH_DIR:-/data/.sshd-config}"
mkdir -p "$SSH_DIR"

# Ensure host keys exist, this must exists for the next steps to work
echo "Persisting ssh config on $SSH_DIR"
if [ ! -f /etc/ssh/ssh_host_ed25519_key ] || [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
    ssh-keygen -A
fi

# This will run on the first step, copy the contents of /etc/ssh to persistent storage
if [ ! -f "$SSH_DIR/sshd_config" ]; then
    cp -af /etc/ssh/. "$SSH_DIR/"
fi

# Harden perms so sshd won’t complain
chown -R root:root "$SSH_DIR"
chown -R root:root /etc/ssh

# Now always copy the contents from the persistent volume to /etch/ssh
cp -af "$SSH_DIR/." /etc/ssh
chmod 700 "$SSH_DIR"
chmod 700 /etc/ssh


# deal with the authorized_keys
printf '%s' "$AUTHORIZED_KEYS" \
  | tr '|' '\n' \
  | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' \
  > /home/sftpuser/.ssh/authorized_keys
chown -R sftpuser:sftpuser /home/sftpuser/.ssh
chmod 700 /home/sftpuser/.ssh
chmod 700 /home/sftpuser/.ssh/authorized_keys

# First ensure that the sshd config is copied
echo "Running sshd on port $SSH_PORT"
envsubst < /defaults/sshd_config > /etc/ssh/sshd_config

# Since the nginx config contains $ envsubst is causing problems
echo "Running nginx on port $HTTP_PORT"
sed "s|\${HTTP_PORT}|$HTTP_PORT|" /etc/nginx/nginx.template > /etc/nginx/nginx.conf
/usr/bin/supervisord -c /etc/supervisor/supervisord.conf -n