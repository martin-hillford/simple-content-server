 #!/usr/bin/env bash
echo "Running sshd on port $SSH_PORT"
envsubst < /etc/sshd/sshd_config_template > /etc/ssh/sshd_config

# Since the nginx config contains $ envsubst is causing problems
echo "Running nginx on port $HTTP_PORT"
sed "s|\${HTTP_PORT}|$HTTP_PORT|" /etc/nginx/nginx.template > /etc/nginx/nginx.conf
/usr/bin/supervisord -c /etc/supervisor/supervisord.conf -n