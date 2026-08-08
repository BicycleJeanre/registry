# Baby Register for Emilia-Rose

A small anonymous baby registry that supports:

- single-claim items, such as a pram
- multi-claim items, such as nappies
- device-local unclaim controls with no personal details
- visitor-added suggestions stored as single-claim items
- a mobile-first interface
- complete local setup and teardown with Podman Compose

## Run locally

Make sure the Podman machine is running:

```sh
podman machine start
```

From this directory, build and start the stack:

```sh
podman compose up --build --detach
```

Open <http://localhost:8080>.

To use another local port:

```sh
REGISTRY_PORT=8081 podman compose up --build --detach
```

## Verify the stack

The smoke test uses only synthetic registry entries and prints pass/fail
results:

```sh
python3 scripts/smoke_test.py
```

The fast application tests can be run in a temporary virtual environment:

```sh
python3 -m venv .venv
.venv/bin/pip install -r requirements-dev.txt
.venv/bin/pytest -q
```

Inspect container status or logs:

```sh
podman compose ps
podman compose logs app
```

## Change the starter items

The starter list is sourced from `../newborn-buying-checklist.md`. Edit
`db/002-buying-checklist-items.sql` to add or update registry entries. Each item
has a `claim_mode`:

- `single`: only one active claim is allowed
- `multiple`: any number of active claims is allowed

The initialization script runs only when Postgres creates a new data volume.
During local development, apply starter-item changes by performing the complete
teardown below and starting the stack again.

## Stop or remove it

Stop the containers while retaining the local database:

```sh
podman compose down
```

Remove the containers and the registry database volume:

```sh
podman compose down --volumes --remove-orphans
```

The second command permanently removes local registry items and claims stored
in this stack. It does not affect other Podman projects.

## Current architecture

The `app` container serves the HTML, CSS, JavaScript, and three small actions:
list items, claim an item, and undo a claim. The `database` container is
available only on the private Compose network; it has no host port.
The app connects using a constrained local role that can read the public item
view and execute only the claim and undo functions. The checked-in credentials
are deliberately local-only and must be replaced before any remote deployment.

Postgres serializes claims per item inside `registry.create_claim`, preventing
two simultaneous visitors from both claiming a single-claim item. Undo tokens
are generated randomly by the app, and only SHA-256 token hashes are stored in
Postgres.
