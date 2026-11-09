#!/bin/sh
set -e

BUNDLE_DIR=$(cd "$(dirname "$0")/.." && pwd)
. "${BUNDLE_DIR}/image_uri.env"

HOST_PORT="${FRONTEND_HOST_PORT:-8080}"
CONTAINER_PORT="${FRONTEND_CONTAINER_PORT:-80}"
DOCKER_NETWORK="${DOCKER_NETWORK:-laravel-app-net}"

docker network create "${DOCKER_NETWORK}" >/dev/null 2>&1 || true

docker run -d \
  --name vue-frontend \
  --restart unless-stopped \
  --network "${DOCKER_NETWORK}" \
  -p "${HOST_PORT}:${CONTAINER_PORT}" \
  "${IMAGE_URI}"
