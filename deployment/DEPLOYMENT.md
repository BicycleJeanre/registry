# Pyramid Demo deployment

The registry runs as an isolated Compose project and does not modify Pyramid's
service on port `8181` or its existing default Nginx site.

## Host layout

- application directory: `/home/jay/apps/emilia-rose-registry`
- registry upstream: `127.0.0.1:18080`
- public hostname: `registry.bicycleclouds.com`
- database: private Compose network only
- persistent data: named Compose volume `registry-data`

## One-time host preparation

These commands require interactive sudo access:

```sh
sudo apt-get update
sudo apt-get install -y docker.io docker-compose-v2
sudo systemctl enable --now docker
sudo usermod -aG docker jay
```

Log out and back in after adding `jay` to the Docker group.

## Start the registry

From the application directory:

```sh
./deployment/create-demo-env.sh
docker compose --env-file .env up -d --build
curl --fail http://127.0.0.1:18080/health
```

The generated `.env` is owner-readable only and must not be committed.

## Enable the hostname

The wildcard certificate must be renewed separately. Once the desired
certificate is installed at the paths already used by Pyramid:

```sh
sudo install -m 0644 deployment/registry.bicycleclouds.com.nginx \
  /etc/nginx/sites-available/registry.bicycleclouds.com
sudo ln -s /etc/nginx/sites-available/registry.bicycleclouds.com \
  /etc/nginx/sites-enabled/registry.bicycleclouds.com
sudo nginx -t
sudo systemctl reload nginx
```

## Validation

```sh
curl --fail http://127.0.0.1:18080/health
curl --fail https://registry.bicycleclouds.com/health
curl --head https://pyramiddemo.bicycleclouds.com/
```

The last check confirms the original Pyramid endpoint still responds through
its unchanged default virtual host.

## Cleanup

Disable only the registry virtual host, reload Nginx, and then remove the
isolated stack:

```sh
sudo rm /etc/nginx/sites-enabled/registry.bicycleclouds.com
sudo nginx -t
sudo systemctl reload nginx
docker compose --env-file .env down --volumes --remove-orphans
```

Removing the Compose volume permanently removes registry items and claims.
