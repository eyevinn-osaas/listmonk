#!/bin/bash
set -e

# OSC Platform: Map PORT to listmonk's address config
# listmonk uses LISTMONK_app__address for its listen address
export LISTMONK_app__address="0.0.0.0:${PORT:-8080}"

# OSC Platform: Parse DATABASE_URL into listmonk's individual DB env vars
if [ -n "$DATABASE_URL" ]; then
  # Extract components from postgresql://user:password@host:port/dbname?params
  proto="$(echo "$DATABASE_URL" | sed -e 's|^\(.*://\).*|\1|')"
  url_no_proto="$(echo "$DATABASE_URL" | sed -e "s|${proto}||")"

  userinfo="$(echo "$url_no_proto" | cut -d@ -f1)"
  hostinfo="$(echo "$url_no_proto" | cut -d@ -f2)"

  db_user="$(echo "$userinfo" | cut -d: -f1)"
  db_pass="$(echo "$userinfo" | cut -d: -f2)"

  hostport="$(echo "$hostinfo" | cut -d/ -f1)"
  db_host="$(echo "$hostport" | cut -d: -f1)"
  db_port="$(echo "$hostport" | cut -d: -f2)"

  db_path="$(echo "$hostinfo" | cut -d/ -f2 | cut -d? -f1)"

  export LISTMONK_db__host="${db_host}"
  export LISTMONK_db__port="${db_port:-5432}"
  export LISTMONK_db__user="${db_user}"
  export LISTMONK_db__password="${db_pass}"
  export LISTMONK_db__database="${db_path}"
  export LISTMONK_db__ssl_mode="${LISTMONK_db__ssl_mode:-disable}"
fi

# OSC Platform: Map uploads to persistent volume if available
if [ -d "/data" ]; then
  mkdir -p /data/uploads
  export LISTMONK_UPLOAD_PATH="/data/uploads"
fi

# Set sensible defaults
export LISTMONK_db__max_open="${LISTMONK_db__max_open:-25}"
export LISTMONK_db__max_idle="${LISTMONK_db__max_idle:-25}"
export LISTMONK_db__max_lifetime="${LISTMONK_db__max_lifetime:-300s}"

exec "$@"
