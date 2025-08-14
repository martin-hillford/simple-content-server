 #!/usr/bin/env bash
echo "Running sshd on port $SSH_PORT"
envsubst < /etc/sshd/sshd_config_template > /etc/ssh/sshd_config

# deal with the authorized_keys
printf '%s' "$AUTHORIZED_KEYS" \
  | tr '|' '\n' \
  | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' \
  > /home/sftpuser/.ssh/authorized_keys
chown -R sftpuser:sftpuser /home/sftpuser/.ssh
chmod 700 /home/sftpuser/.ssh
chmod 700 /home/sftpuser/.ssh/authorized_keys

# Since the nginx config contains $ envsubst is causing problems
echo "Running nginx on port $HTTP_PORT"
sed "s|\${HTTP_PORT}|$HTTP_PORT|" /etc/nginx/nginx.template > /etc/nginx/nginx.conf
/usr/bin/supervisord -c /etc/supervisor/supervisord.conf -n