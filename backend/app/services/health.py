from __future__ import annotations

from sqlalchemy import text

from app.db.session import SessionLocal
from app.services.cache import get_redis


def check_database() -> dict:
    try:
        db = SessionLocal()
        try:
            db.execute(text('SELECT 1'))
        finally:
            db.close()
        return {'status': 'ok'}
    except Exception as exc:
        return {'status': 'error', 'message': str(exc)}


def check_redis() -> dict:
    try:
        get_redis().ping()
        return {'status': 'ok'}
    except Exception as exc:
        return {'status': 'error', 'message': str(exc)}