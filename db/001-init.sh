#!/bin/sh
set -eu

: "${POSTGRES_USER:?POSTGRES_USER is required}"
: "${POSTGRES_DB:?POSTGRES_DB is required}"
: "${REGISTRY_APP_DB_PASSWORD:?REGISTRY_APP_DB_PASSWORD is required}"

psql \
    --username "$POSTGRES_USER" \
    --dbname "$POSTGRES_DB" \
    --set=ON_ERROR_STOP=1 \
    --set=registry_app_password="$REGISTRY_APP_DB_PASSWORD" \
    --file=/registry-init/init.sql
