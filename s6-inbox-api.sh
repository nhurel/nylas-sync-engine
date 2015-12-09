#!/bin/sh
export REPLACE_VARS='$MYSQL_ENV_MYSQL_ROOT_PASSWORD:$MYSQL_PORT_3306_TCP_PORT'
envsubst "$REPLACE_VARS" < /etc/inboxapp/config-env.json > /etc/inboxapp/config.json
envsubst "$REPLACE_VARS" < /etc/inboxapp/secrets-env.yml > /etc/inboxapp/secrets.yml

# inbox-start startup command
s6-setuidgid inbox /opt/sync-engine/bin/inbox-api
