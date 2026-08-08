#!/bin/sh
set -eu

target=${1:-.env}

if [ -e "$target" ]; then
    echo "Refusing to overwrite existing $target" >&2
    exit 1
fi

umask 077
database_password=$(openssl rand -hex 32)
app_password=$(openssl rand -hex 32)

{
    echo "REGISTRY_PROJECT_NAME=emilia-rose-registry"
    echo "REGISTRY_DB_PASSWORD=$database_password"
    echo "REGISTRY_APP_DB_PASSWORD=$app_password"
    echo "REGISTRY_BIND_ADDRESS=127.0.0.1"
    echo "REGISTRY_PORT=18080"
} > "$target"

echo "Created $target with permissions restricted to its owner."
