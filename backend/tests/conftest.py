from __future__ import annotations

import os
from pathlib import Path

import fakeredis
import pytest
from fastapi.testclient import TestClient


TEST_DB_PATH = Path(__file__).resolve().parent / 'test.sqlite3'
os.environ['DATABASE_URL'] = f'sqlite:///{TEST_DB_PATH.as_posix()}'
os.environ['REDIS_URL'] = 'redis://localhost:6379/15'
os.environ['JWT_SECRET'] = 'test-secret'

from app.db.models import Base
from app.db.seed import seed_database
from app.db.session import SessionLocal, engine
from app.main import app
from app.services import cache


@pytest.fixture(autouse=True)
def reset_state():
    engine.dispose()
    Base.metadata.drop_all(bind=engine)
    Base.metadata.create_all(bind=engine)
    fake_redis = fakeredis.FakeRedis(decode_responses=True)
    cache._redis_client = fake_redis

    db = SessionLocal()
    try:
        seed_database(db)
    finally:
        db.close()

    yield

    engine.dispose()
    Base.metadata.drop_all(bind=engine)
    cache._redis_client = None


@pytest.fixture
def client():
    with TestClient(app) as test_client:
        yield test_client