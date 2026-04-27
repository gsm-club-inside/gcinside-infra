# Network Topology

```
+---------------------+        +-----------------------+
|   gcinside-app      |  HTTP  |  gcinside-ai-inference |
|   (Next.js, public) | -----> |  (private, 8081)       |
+----------+----------+        +-----------------------+
           |  Postgres                ^
           |  Redis                   |  Object Storage (model artifact)
           v                          |
+---------------------+               |
|   PostgreSQL        |<--+           |
+---------------------+   |           |
                          |           |
+---------------------+   |   +-----------------------+
|   Redis             |<--+   |  Object Storage (S3 / |
+---------------------+       |   GCS / MinIO)        |
                              +-----------------------+
                                         ^
+---------------------+      +-----------------------+
| gcinside-abuse-     |      | gcinside-ml-pipeline   |
| worker (private)    | ---> | (batch / cron)         |
+---------------------+      +-----------------------+
        |                    |
        v                    v
   Queue (SQS / Redis Streams / Kafka)
```

## Reach rules

- 메인 앱(`gcinside-app`)만 public.
- `gcinside-ai-inference` 는 private network only — 메인 앱에서만 호출.
- `gcinside-abuse-worker` 는 외부 inbound 없음.
- `gcinside-ml-pipeline` 은 batch — 외부 inbound 없음.
- DB / Redis / Queue / Object Storage 는 private subnet only.
