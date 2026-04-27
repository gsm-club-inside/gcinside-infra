# Secrets

## 필수

| Secret | 사용 서비스 | 비고 |
|---|---|---|
| `DATABASE_URL` | app, worker, ml-pipeline | PG 연결 |
| `DIRECT_URL` | app | Prisma migrate 용 (PgBouncer 우회) |
| `OAUTH_CLIENT_SECRET` | app | hellogsm.kr OAuth |
| `SESSION_SECRET` | app | iron-session 암호화 키 (>=32자) |
| `ABUSE_HASH_SALT` | app, (worker) | IP/device hash salt — 변경 시 모든 hash 무효 |
| `AI_INFERENCE_TOKEN` | app(client), ai-inference(server) | Bearer |
| `MINIO_ROOT_PASSWORD` / S3 credentials | ai-inference, ml-pipeline, worker | object storage |
| `REDIS_URL` (with auth) | app, worker | rate-limit / cache |
| `QUEUE_URL` (with auth) | app, worker | abuse event queue |

## 회전 정책

- `SESSION_SECRET` 회전 시: 모든 사용자 재로그인 필요 → 점검 공지 후 회전.
- `ABUSE_HASH_SALT` 회전 시: 누적 IP/device hash 가 분리됨 → 회전은 신중히. 회전 시 새 salt 로 재계산하지 말고 새 시점부터 분리해서 관리.
- `AI_INFERENCE_TOKEN` 회전: rolling restart 가능 (메인 앱 client + ai-inference 서버 모두 새 값 주입 후 옛 값 제거).

## 저장 권장

- AWS: Secrets Manager + IAM role per service
- GCP: Secret Manager + workload identity
- self-host: SOPS / age-encrypted YAML in `gcinside-infra/env/`

`.env` 파일은 절대 commit 금지 — 각 서비스 `.env.example` 만 commit.
