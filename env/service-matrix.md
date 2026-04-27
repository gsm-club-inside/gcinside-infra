# Service Env Matrix

| Variable | gcinside-app | ai-inference | abuse-worker | ml-pipeline |
|---|---|---|---|---|
| `DATABASE_URL` | Y | - | Y | Y |
| `DIRECT_URL` | Y | - | - | - |
| `REDIS_URL` | (future) | - | Y | - |
| `OBJECT_STORAGE_URL` | - | (model artifact) | (feature snapshot) | Y |
| `QUEUE_URL` | (audit publisher) | - | Y | - |
| `OAUTH_CLIENT_ID` / `_SECRET` / `_REDIRECT_URI` | Y | - | - | - |
| `SESSION_SECRET` | Y | - | - | - |
| `ADMIN_EMAILS` | Y | - | - | - |
| `ABUSE_HASH_SALT` | Y | - | (if rehashing) | - |
| `ABUSE_RULE_VERSION` | Y | - | (audit only) | - |
| `ABUSE_ENABLE_HARD_BLOCK` | Y | - | - | - |
| `ABUSE_FAIL_OPEN` | Y | - | - | - |
| `ABUSE_SHADOW_MODE` | Y | - | - | - |
| `ABUSE_CANARY_RATIO` | Y | - | - | - |
| `ABUSE_MODEL_ROLLBACK` | Y | - | - | - |
| `AI_INFERENCE_URL` | Y | - | - | - |
| `AI_INFERENCE_TOKEN` | Y | Y (server) | - | - |
| `AI_INFERENCE_TIMEOUT_MS` / `_RETRIES` / `_ENABLED` | Y | - | - | - |
| `MODEL_NAME` | - | Y | - | - |
| `MODEL_PATH` | - | Y | - | - |
| `MODEL_REGISTRY_PATH` | - | (consumer) | - | Y |
| `FEATURE_EXPORT_PATH` | - | - | - | Y |
| `DRIFT_BASELINE_PATH` | - | - | - | Y |
| `LOG_LEVEL` | Y | Y | Y | Y |
