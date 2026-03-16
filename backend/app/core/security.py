from __future__ import annotations

from datetime import UTC, datetime, timedelta
from uuid import uuid4

import jwt
from passlib.context import CryptContext

from app.core.config import get_settings


pwd_context = CryptContext(schemes=['pbkdf2_sha256'], deprecated='auto')


def hash_password(password: str) -> str:
    return pwd_context.hash(password)


def verify_password(password: str, password_hash: str) -> bool:
    return pwd_context.verify(password, password_hash)


def _create_token(subject: str, token_type: str, expires_delta: timedelta, family_id: str | None = None) -> str:
    settings = get_settings()
    now = datetime.now(UTC)
    expires_at = now + expires_delta
    payload = {
        'sub': subject,
        'type': token_type,
        'jti': uuid4().hex,
        'iat': int(now.timestamp()),
        'exp': int(expires_at.timestamp()),
    }
    if family_id is not None:
        payload['family_id'] = family_id
    return jwt.encode(payload, settings.jwt_secret, algorithm=settings.jwt_algorithm)


def create_access_token(subject: str, family_id: str | None = None) -> str:
    settings = get_settings()
    return _create_token(subject, 'access', timedelta(minutes=settings.access_token_expire_minutes), family_id=family_id)


def create_refresh_token(subject: str, family_id: str | None = None) -> str:
    settings = get_settings()
    return _create_token(subject, 'refresh', timedelta(days=settings.refresh_token_expire_days), family_id=family_id)


def decode_token(token: str, expected_type: str | None = None) -> dict:
    settings = get_settings()
    payload = jwt.decode(token, settings.jwt_secret, algorithms=[settings.jwt_algorithm])
    if expected_type and payload.get('type') != expected_type:
        raise jwt.InvalidTokenError('Invalid token type')
    return payload