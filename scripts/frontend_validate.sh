#!/bin/sh
set -e

CHECK_URL="${FRONTEND_HEALTHCHECK_URL:-http://127.0.0.1:8080/}"

i=0
while [ "${i}" -lt 30 ]; do
  if curl -fsS "${CHECK_URL}" >/dev/null 2>&1; then
    echo "Vue frontend is healthy"
    exit 0
  fi
  i=$((i + 1))
  sleep 2
done

echo "Vue frontend failed health check at ${CHECK_URL}" >&2
exit 1
