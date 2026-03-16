# Qaida Backend

FastAPI backend for the Qaida mobile flows inferred from the UI kit.

## Stack

- FastAPI
- SQLAlchemy 2.x
- Alembic
- PostgreSQL
- Redis
- Docker Compose
- JWT auth

## Run locally

```bash
docker compose up --build
```

API docs:

- Swagger UI: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc

Demo behavior:

- The app seeds demo data on first startup.
- Migrations are applied automatically before the API starts.
- Use /api/v1/auth/register or /api/v1/auth/login to obtain JWT tokens.

Demo credentials:

- email: demo@qaida.app
- password: qaida-demo

Auth:

- Swagger authorize button uses bearer JWT.
- Protected endpoints require Authorization: Bearer <accessToken>.

## Development commands

Using Makefile:

- make dev-up
- make dev-down
- make logs
- make migrate-up
- make migrate-create message="add feature"
- make api-shell

Using VS Code tasks:

- Dev: Compose Up
- Dev: Compose Down
- Dev: API Logs
- DB: Alembic Upgrade Head
- DB: Alembic Autogenerate Revision
