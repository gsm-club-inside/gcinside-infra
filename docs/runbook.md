# Runbook

## 로컬 실행 순서

1. `cp gcinside-infra/compose/.env.example gcinside-infra/compose/.env`
2. `cd gcinside-infra/compose && docker compose up -d postgres redis minio`
3. Postgres health 확인 (`pg_isready`).
4. `cd ../../gcinside-app && cp .env.example .env`, env 채우고 `npm install && npm run db:migrate && npm run dev`
5. (선택) `cd ../gcinside-ai-inference && pip install -r requirements-dev.txt && uvicorn app.main:app --port 8081`
6. (선택) `cd ../gcinside-abuse-worker && npm install && npm run dev`
7. (선택) `cd ../gcinside-ml-pipeline && pip install -r requirements-dev.txt && pip install -e . && gcml schema`

## 배포 순서

1. `gcinside-infra` 의 PG / Redis / Object Storage / Queue 가 먼저 준비되어 있어야 함.
2. `gcinside-ai-inference` 배포 (모델 artifact 가 Object Storage 에 있으면 mount).
3. `gcinside-abuse-worker` 배포 (Queue / DB 연결 확인).
4. `gcinside-app` 배포 — `AI_INFERENCE_URL` 가 ai-inference 의 private endpoint 를 가리키도록.
5. `gcinside-ml-pipeline` 은 cron / Airflow / batch 트리거.

## Backup / Retention

- PostgreSQL: 매일 자동 스냅샷, 30일 보관 권장.
- AbuseEvent / RiskDecisionRecord: 90일 retention 권장. 그 이후는 ml-pipeline 으로 export 후 PG 에서 삭제.
- Redis: ephemeral, backup 불필요. RDB snapshot 은 옵션.
- Object Storage (model artifact): immutable + versioned bucket 권장.

## 운영 시 주의사항

- `ABUSE_ENABLE_HARD_BLOCK=true` 로 올리기 전에 최소 1주 shadow mode 또는 monitor 모드 운영.
- `ABUSE_HASH_SALT` 는 함부로 회전하지 않는다 — 누적된 reputation 이 끊긴다.
- AI inference 가 down 이어도 메인 앱은 동작해야 한다 (`ABUSE_FAIL_OPEN=true` 가 기본).
- 운영 중 룰 점수/임계값 조정은 `ABUSE_RULE_VERSION` 을 함께 올려서 audit 에 남도록.
- 어드민 unblock / reputation reset 은 모두 audit 사유와 함께 기록.
