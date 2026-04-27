# Observability

## 로그
- 모든 서비스는 stdout JSON 라인.
- `LOG_LEVEL` env 로 통제.
- request id (`requestId`) 를 anti-abuse audit 에 일관되게 부여 (`gcinside-app/src/lib/abuse/orchestrator.ts`).

## 메트릭 (placeholder)
- gcinside-app: Next.js native metrics, custom abuse counter (rule hit / decision level / AI failure).
- ai-inference: predict latency p50/p95, model_version 라벨링.
- abuse-worker: queue depth, handler error rate, expired temp blocks count.
- ml-pipeline: 학습 시간, 평가 metric, drift flagged count.

## 추적
- OpenTelemetry SDK 적용 권장 (현재는 placeholder). 서비스 간 호출 (app→ai-inference) 에 W3C traceparent 전파 권장.

## 알람 (예시)
- `decision="HARD_BLOCK"` rate > 5%/5min → 운영 채널 알람
- AI inference p95 latency > timeout 의 80% → 모델 점검
- temp block 만료 미작동 (worker queue 정체) → on-call
- drift flagged > N → ml-pipeline 검토 라벨
