SHELL := /bin/sh

.PHONY: dev-up dev-down logs migrate-up migrate-create api-shell db-shell test

dev-up:
	docker compose up --build

dev-down:
	docker compose down

logs:
	docker compose logs -f api

migrate-up:
	docker compose run --rm api alembic upgrade head

migrate-create:
	@test -n "$(message)" || (echo "usage: make migrate-create message='your message'" && exit 1)
	docker compose run --rm api alembic revision --autogenerate -m "$(message)"

api-shell:
	docker compose run --rm api sh

db-shell:
	docker compose exec db psql -U qaida -d qaida

test:
	docker compose run --rm api pytest
