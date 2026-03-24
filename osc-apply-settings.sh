#!/bin/bash
# osc-apply-settings.sh — update listmonk DB settings from OSC platform env vars.
# Called every boot between --install and --upgrade so OSC-provided values always win.
set -e

if [ -z "$OSC_HOSTNAME" ]; then
  echo "osc-apply-settings: OSC_HOSTNAME not set, skipping settings update"
  exit 0
fi

if [ -z "$LISTMONK_db__host" ]; then
  echo "osc-apply-settings: DB env vars not set, skipping settings update"
  exit 0
fi

ROOT_URL="https://${OSC_HOSTNAME}"

echo "osc-apply-settings: setting app.root_url=${ROOT_URL}"

PGPASSWORD="${LISTMONK_db__password}" psql \
  -h "${LISTMONK_db__host}" \
  -p "${LISTMONK_db__port:-5432}" \
  -U "${LISTMONK_db__user}" \
  -d "${LISTMONK_db__database}" \
  --no-password \
  -c "UPDATE settings SET value = jsonb_set(value::jsonb, '{app.root_url}', to_jsonb('${ROOT_URL}'::text)) WHERE 1=1"

echo "osc-apply-settings: done"
