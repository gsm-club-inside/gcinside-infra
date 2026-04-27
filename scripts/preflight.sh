#!/usr/bin/env sh
set -eu

ROOT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
WORKSPACE_DIR="$(CDPATH= cd -- "$ROOT_DIR/.." && pwd)"

missing=0

check_file() {
  if [ ! -f "$1" ]; then
    printf 'missing: %s\n' "$1"
    missing=1
  else
    printf 'ok: %s\n' "$1"
  fi
}

check_dir() {
  if [ ! -d "$1" ]; then
    printf 'missing: %s\n' "$1"
    missing=1
  else
    printf 'ok: %s\n' "$1"
  fi
}

printf 'workspace: %s\n' "$WORKSPACE_DIR"

check_dir "$WORKSPACE_DIR/gcinside-app"
check_dir "$WORKSPACE_DIR/gcinside-ai-inference"
check_dir "$WORKSPACE_DIR/gcinside-abuse-worker"
check_dir "$WORKSPACE_DIR/gcinside-ml-pipeline"
check_dir "$WORKSPACE_DIR/gcinside-infra"

check_file "$WORKSPACE_DIR/gcinside-app/Dockerfile"
check_file "$WORKSPACE_DIR/gcinside-ai-inference/Dockerfile"
check_file "$WORKSPACE_DIR/gcinside-abuse-worker/Dockerfile"
check_file "$WORKSPACE_DIR/gcinside-ml-pipeline/Dockerfile"
check_file "$ROOT_DIR/docker-compose.yml"
check_file "$ROOT_DIR/Caddyfile"
check_file "$ROOT_DIR/.env"

if command -v docker >/dev/null 2>&1; then
  docker --version
else
  printf 'missing: docker command\n'
  missing=1
fi

if docker compose version >/dev/null 2>&1; then
  docker compose version
else
  printf 'missing: docker compose plugin\n'
  missing=1
fi

if [ "$missing" -ne 0 ]; then
  printf '\npreflight failed. Fix the missing items above before deploying.\n'
  exit 1
fi

printf '\npreflight passed.\n'
