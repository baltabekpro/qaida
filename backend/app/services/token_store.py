from __future__ import annotations

from datetime import UTC, datetime

from app.services.cache import get_redis


def _token_key(jti: str) -> str:
    return f'token:blacklist:{jti}'


def _family_key(family_id: str) -> str:
    return f'token:family:active:{family_id}'


def _family_revoked_key(family_id: str) -> str:
    return f'token:family:revoked:{family_id}'


def revoke_token(jti: str, exp: int) -> None:
    ttl = max(exp - int(datetime.now(UTC).timestamp()), 1)
    get_redis().setex(_token_key(jti), ttl, '1')


def is_token_revoked(jti: str | None) -> bool:
    if not jti:
        return True
    return bool(get_redis().exists(_token_key(jti)))


def set_active_family_token(family_id: str, jti: str, exp: int) -> None:
    ttl = max(exp - int(datetime.now(UTC).timestamp()), 1)
    get_redis().setex(_family_key(family_id), ttl, jti)


def get_active_family_token(family_id: str | None) -> str | None:
    if not family_id:
        return None
    value = get_redis().get(_family_key(family_id))
    return value if value else None


def revoke_family(family_id: str, exp: int) -> None:
    ttl = max(exp - int(datetime.now(UTC).timestamp()), 1)
    redis = get_redis()
    redis.setex(_family_revoked_key(family_id), ttl, '1')
    redis.delete(_family_key(family_id))


def is_family_revoked(family_id: str | None) -> bool:
    if not family_id:
        return False
    return bool(get_redis().exists(_family_revoked_key(family_id)))