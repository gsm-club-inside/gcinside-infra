# GCinside Infra

This infra repository runs the GCinside services together with Docker Compose.

Expected sibling directories:

```text
GC/
  gcinside-app/
  gcinside-ai-inference/
  gcinside-abuse-worker/
  gcinside-ml-pipeline/
  gcinside-infra/
```

## Services

`docker-compose.yml` starts:

- `caddy`: public HTTPS reverse proxy with automatic Let's Encrypt certificates
- `app`: Next.js main app, proxied internally by Caddy
- `ai-inference`: internal AI risk scoring API
- `abuse-worker`: internal async abuse analysis worker
- `postgres`: PostgreSQL 16
- `redis`: Redis 7
- `queue`: NATS JetStream
- `object-storage`: MinIO

`ml-pipeline` is registered as a compose profile named `jobs`, so it does not run continuously by default.

## First Deploy

Install Docker and the Compose plugin on the server, then from `gcinside-infra`:

```bash
cp .env.example .env
```

Edit `.env` and replace every `CHANGE_ME` value.

Set these values before starting the stack:

```bash
GCINSIDE_DOMAIN=gcinside.zaewc.site
ACME_EMAIL=admin@your-domain.com
HTTP_BIND_ADDR=127.0.0.1
HTTP_HOST_PORT=8080
HTTPS_BIND_ADDR=0.0.0.0
HTTPS_HOST_PORT=25128
NEXTAUTH_URL=https://gcinside.zaewc.site:25128
OAUTH_REDIRECT_URI=https://gcinside.zaewc.site:25128/api/auth/callback
APP_BASE_URL=https://gcinside.zaewc.site:25128
SESSION_COOKIE_SECURE=true
```

Your domain must already have an `A` or `AAAA` record pointing to the Linux server. If public ports `80` and `443` are unavailable, bind HTTPS to an allowed public port such as `25128` and use that port in every public app URL and OAuth redirect URL. A trusted certificate still needs DNS validation because ACME HTTP/TLS challenges require the standard `80`/`443` ports.

Run a quick preflight check:

```bash
sh scripts/preflight.sh
```

Build and start:

```bash
docker compose build
docker compose up -d
```

Check status:

```bash
docker compose ps
docker compose logs -f app
```

The app should be available on:

```text
https://gcinside.zaewc.site:25128
```

The direct app port is bound to `127.0.0.1:${APP_HOST_PORT:-3000}` for local debugging only.

## Run ML Pipeline Job

The ML pipeline is not a daemon. Run it only when needed:

```bash
docker compose --profile jobs run --rm ml-pipeline
```

If the pipeline repo exposes a specific command, append it:

```bash
docker compose --profile jobs run --rm ml-pipeline python -m gcinside_ml_pipeline.export
```

## Network Exposure

Only Caddy is publicly bound by default. When standard web ports are unavailable, set `HTTP_BIND_ADDR=127.0.0.1`, `HTTP_HOST_PORT=8080`, and `HTTPS_HOST_PORT=25128` so plaintext HTTP stays local and HTTPS is exposed on the allowed public port.

The app debug port, PostgreSQL, Redis, NATS, and MinIO ports are bound to `127.0.0.1` for local server access only. Service-to-service traffic uses the private Docker network.

Caddy stores issued certificates in the `caddy-data` Docker volume and renews them automatically.

## Common Commands

```bash
docker compose pull
docker compose build --no-cache
docker compose up -d
docker compose ps
docker compose logs -f --tail=200
docker compose restart app
docker compose down
```

Do not run `docker compose down -v` unless you intentionally want to delete PostgreSQL, Redis, NATS, and MinIO data volumes.

## Backups

At minimum, back up:

- `caddy-data`, for issued TLS certificates and Caddy state
- `postgres-data`
- `redis-data`, if temporary abuse state matters
- `nats-data`, if queued events must survive a restore
- `minio-data`, for feature exports and model artifacts

PostgreSQL is the most important persistent store.
