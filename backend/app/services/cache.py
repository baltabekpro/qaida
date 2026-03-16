from __future__ import annotations

import json

from redis import Redis
from redis.exceptions import RedisError

from app.core.config import get_settings


_redis_client: Redis | None = None


def get_redis() -> Redis:
    global _redis_client
    if _redis_client is None:
        settings = get_settings()
        _redis_client = Redis.from_url(settings.redis_url, decode_responses=True)
    return _redis_client


def get_json(key: str):
    try:
        raw = get_redis().get(key)
        return json.loads(raw) if raw else None
    except (RedisError, json.JSONDecodeError):
        return None


def set_json(key: str, value, ttl: int = 300) -> None:
    try:
        get_redis().setex(key, ttl, json.dumps(value, default=str))
    except RedisError:
        return None
