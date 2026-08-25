# LifeMoney v0.2

India-first **life and money simulator** with a modern Flutter mobile UI and a FastAPI calculation engine.

## What changed in v0.2

### Premium mobile UI

- Modern Material 3 design system
- Wealth dashboard
- Safe-to-spend and FIRE summary cards
- Goal progress experience
- Quick simulation actions
- Dream Mode
- Goal Planner with compact assumptions
- Retirement / FIRE simulator
- Can-I-Afford-It decision screen
- Clear result hierarchy instead of raw calculator output

The dashboard values are illustrative until profile persistence is added.

### Cloud-ready backend

- Production Dockerfile
- Non-root container user
- Environment-driven port
- Multiple Uvicorn workers
- Configurable CORS
- `/health` endpoint
- Railway persistent-service configuration
- GitHub CI tests

The backend remains stateless in v0.2, which keeps the first cloud deployment simple and avoids storing sensitive financial data prematurely.

## Project layout

```text
lifemoney-v0.2/
├── backend/
│   ├── app/
│   │   ├── main.py
│   │   ├── schemas.py
│   │   └── money_engine/
│   ├── tests/
│   ├── Dockerfile
│   ├── railway.toml
│   └── requirements.txt
├── mobile/
│   ├── lib/
│   │   ├── screens/
│   │   ├── theme/
│   │   ├── utils/
│   │   ├── widgets/
│   │   ├── api.dart
│   │   └── main.dart
│   ├── bootstrap_mobile.ps1
│   └── pubspec.yaml
├── .github/workflows/backend-ci.yml
└── CLOUD_DEPLOYMENT.md
```

## Backend — local verification

```powershell
cd backend
py -m venv .venv
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\.venv\Scripts\Activate.ps1
python -m pip install -r requirements.txt
pytest -q
python -m uvicorn app.main:app --reload --port 8000
```

Open:

```text
http://127.0.0.1:8000/docs
```

## Mobile — Windows setup

```powershell
cd mobile
.\bootstrap_mobile.ps1
```

After the API is deployed to the cloud:

```powershell
flutter run --dart-define=API_BASE_URL=https://YOUR-CLOUD-API-DOMAIN
```

The Flutter app then talks directly to the HTTPS cloud backend. You do **not** need the Python server running locally.

## Cloud deployment

See [CLOUD_DEPLOYMENT.md](CLOUD_DEPLOYMENT.md).

Recommended MVP flow:

```text
GitHub -> Railway persistent FastAPI service -> HTTPS API -> Flutter app
```

For public production, we can later move the same backend container to AWS App Runner/ECS and add PostgreSQL, authentication, secrets management, logging, rate limits, staging, backups and observability.

## API endpoints

- `GET /`
- `GET /health`
- `POST /v1/goals/calculate`
- `POST /v1/retirement/simulate`
- `POST /v1/affordability/check`

## Current safety boundary

LifeMoney v0.2 performs planning and simulation. It does not recommend specific securities or mutual funds, execute transactions, or collect banking credentials.
