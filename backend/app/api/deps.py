from __future__ import annotations

import jwt
from fastapi import Depends, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy.orm import Session

from app.core.errors import api_error
from app.core.security import decode_token
from app.db.models import User
from app.db.session import get_db
from app.services.token_store import is_family_revoked, is_token_revoked


bearer_optional = HTTPBearer(auto_error=False)
bearer_required = HTTPBearer(auto_error=True)


def _decode_access_credentials(credentials: HTTPAuthorizationCredentials | None) -> dict | None:
    if credentials is None:
        return None
    try:
        payload = decode_token(credentials.credentials, expected_type='access')
    except jwt.InvalidTokenError as exc:
        raise api_error(status.HTTP_401_UNAUTHORIZED, 'invalid_token', 'Invalid or expired access token') from exc
    if is_token_revoked(payload.get('jti')):
        raise api_error(status.HTTP_401_UNAUTHORIZED, 'revoked_token', 'Access token has been revoked')
    if is_family_revoked(payload.get('family_id')):
        raise api_error(status.HTTP_401_UNAUTHORIZED, 'revoked_session', 'Session has been revoked')
    return payload


def _resolve_user(credentials: HTTPAuthorizationCredentials | None, db: Session) -> User | None:
    payload = _decode_access_credentials(credentials)
    if payload is None:
        return None
    user = db.get(User, payload.get('sub'))
    if user is None or not user.is_active:
        raise api_error(status.HTTP_401_UNAUTHORIZED, 'user_not_found', 'Authenticated user not found')
    return user


def get_optional_current_user(
    credentials: HTTPAuthorizationCredentials | None = Depends(bearer_optional),
    db: Session = Depends(get_db),
) -> User | None:
    return _resolve_user(credentials, db)


def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(bearer_required),
    db: Session = Depends(get_db),
) -> User:
    user = _resolve_user(credentials, db)
    if user is None:
        raise api_error(status.HTTP_401_UNAUTHORIZED, 'authentication_required', 'Authentication required')
    return user


def get_current_access_payload(credentials: HTTPAuthorizationCredentials = Depends(bearer_required)) -> dict:
    payload = _decode_access_credentials(credentials)
    if payload is None:
        raise api_error(status.HTTP_401_UNAUTHORIZED, 'authentication_required', 'Authentication required')
    return payload