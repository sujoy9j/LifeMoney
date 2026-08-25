# LifeMoney v0.2 — Cloud deployment

## Recommended MVP topology

```text
Flutter iOS / Android
        |
        | HTTPS
        v
Railway public domain
        |
        v
FastAPI container (persistent service)
        |
        +-- /health
        +-- /docs
        +-- /v1/goals/calculate
        +-- /v1/retirement/simulate
        +-- /v1/affordability/check
```

For the MVP, Railway is intentionally used for the stateless FastAPI service because it can deploy directly from GitHub and keep a persistent container running. For a regulated production release, the same Docker image can later move to AWS App Runner/ECS without changing the finance engine.

## 1. Put the repository in GitHub

Push the complete `lifemoney-v0.2` directory to a private GitHub repository.

The included GitHub Actions workflow runs the backend tests on every backend change.

## 2. Create the Railway service

1. Create a Railway project.
2. Choose **Deploy from GitHub repo**.
3. Select the LifeMoney repository.
4. Set the service root directory to `/backend`.
5. Set the config file path to `/backend/railway.toml` if Railway does not discover it automatically.
6. Confirm the Dockerfile is `/backend/Dockerfile`.
7. Keep **Serverless / App Sleeping disabled** for this API.
8. Use a paid persistent service if you require 24×7 availability and the `ALWAYS` restart policy.
9. Generate a public HTTPS domain in Networking.

No database is required for v0.2 because every calculation is stateless.

## 3. Environment variables

For the first private test:

```text
CORS_ORIGINS=*
WEB_CONCURRENCY=2
```

Before public web use, replace `*` with the actual approved origins.

Railway supplies `PORT`; the Docker container listens on it automatically.

## 4. Validate cloud deployment

Replace the sample host below with the generated domain:

```text
https://your-lifemoney-api.up.railway.app/health
https://your-lifemoney-api.up.railway.app/docs
```

Expected health response:

```json
{
  "status": "ok",
  "version": "0.2.0"
}
```

## 5. Point Flutter to the cloud API

Local Android/iOS development against the cloud API:

```powershell
flutter run --dart-define=API_BASE_URL=https://your-lifemoney-api.up.railway.app
```

Android production build:

```powershell
flutter build appbundle --release --dart-define=API_BASE_URL=https://your-lifemoney-api.up.railway.app
```

iOS production build (macOS required):

```bash
flutter build ipa --release --dart-define=API_BASE_URL=https://your-lifemoney-api.up.railway.app
```

The mobile app no longer needs the Python server running on your PC once `API_BASE_URL` points to the cloud domain.

## 6. Production hardening roadmap

Before App Store / Play production launch:

- Add authentication and user/household tenancy.
- Add PostgreSQL with encrypted-at-rest user data.
- Add API rate limiting and abuse protection.
- Restrict CORS.
- Add centralized error tracking and audit logs.
- Add secrets management instead of repository secrets.
- Add backup / restore controls.
- Add a staging environment before production.
- Add continuous external uptime monitoring.
- Add India DPDP consent and deletion workflows before storing personal financial information.
