from __future__ import annotations

import jwt
from uuid import uuid4

from fastapi import APIRouter, Depends, status
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.api.deps import get_current_access_payload, get_current_user
from app.api.utils import user_to_profile
from app.core.config import get_settings
from app.core.errors import api_error
from app.core.security import create_access_token, create_refresh_token, decode_token, hash_password, verify_password
from app.db.models import BudgetRange, CompanyType, NotificationType, User
from app.db.session import get_db
from app.schemas.common import AcceptedResponse, AuthUserOut, LoginRequest, LogoutRequest, RefreshTokenRequest, RegisterRequest, TokenResponse, UserProfileOut
from app.services.token_store import get_active_family_token, is_family_revoked, is_token_revoked, revoke_family, revoke_token, set_active_family_token


router = APIRouter(tags=['Auth'])


def token_response_for_user(user: User, family_id: str | None = None) -> TokenResponse:
    settings = get_settings()
    resolved_family_id = family_id or str(uuid4())
    access_token = create_access_token(user.id, family_id=resolved_family_id)
    refresh_token = create_refresh_token(user.id, family_id=resolved_family_id)
    refresh_payload = decode_token(refresh_token, expected_type='refresh')
    set_active_family_token(resolved_family_id, refresh_payload['jti'], refresh_payload['exp'])
    return TokenResponse(
        access_token=access_token,
        refresh_token=refresh_token,
        expires_in=settings.access_token_expire_minutes * 60,
        user=AuthUserOut(id=user.id, name=user.name, email=user.email),
    )


@router.post('/auth/register', response_model=TokenResponse, status_code=status.HTTP_201_CREATED)
def register(payload: RegisterRequest, db: Session = Depends(get_db)):
    if db.scalar(select(User).where(User.email == payload.email)) is not None:
        raise api_error(status.HTTP_400_BAD_REQUEST, 'email_taken', 'User with this email already exists')
    user = User(
        name=payload.name,
        email=payload.email,
        password_hash=hash_password(payload.password),
        avatar_url=payload.avatarUrl,
        is_active=True,
        company_type=CompanyType.FRIENDS,
        favorite_categories=[],
        budget=BudgetRange.MEDIUM,
        notifications_enabled=True,
        enabled_notification_types=[item.value for item in NotificationType],
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    return token_response_for_user(user)


@router.post('/auth/login', response_model=TokenResponse)
def login(payload: LoginRequest, db: Session = Depends(get_db)):
    user = db.scalar(select(User).where(User.email == payload.email))
    if user is None or not verify_password(payload.password, user.password_hash):
        raise api_error(status.HTTP_401_UNAUTHORIZED, 'invalid_credentials', 'Invalid email or password')
    if not user.is_active:
        raise api_error(status.HTTP_401_UNAUTHORIZED, 'inactive_user', 'User account is inactive')
    return token_response_for_user(user)


@router.post('/auth/refresh', response_model=TokenResponse)
def refresh_token(payload: RefreshTokenRequest, db: Session = Depends(get_db)):
    try:
        decoded = decode_token(payload.refreshToken, expected_type='refresh')
    except jwt.InvalidTokenError as exc:
        raise api_error(status.HTTP_401_UNAUTHORIZED, 'invalid_refresh_token', 'Invalid or expired refresh token') from exc

    family_id = decoded.get('family_id')
    if is_family_revoked(family_id):
        raise api_error(status.HTTP_401_UNAUTHORIZED, 'revoked_refresh_family', 'Refresh token family has been revoked')

    active_jti = get_active_family_token(family_id)
    if active_jti != decoded.get('jti') or is_token_revoked(decoded.get('jti')):
        revoke_family(family_id, decoded['exp'])
        revoke_token(decoded['jti'], decoded['exp'])
        raise api_error(status.HTTP_401_UNAUTHORIZED, 'refresh_token_reuse_detected', 'Refresh token reuse detected')

    user = db.get(User, decoded.get('sub'))
    if user is None or not user.is_active:
        raise api_error(status.HTTP_401_UNAUTHORIZED, 'user_not_found', 'Authenticated user not found')
    revoke_token(decoded['jti'], decoded['exp'])
    return token_response_for_user(user, family_id=family_id)


@router.post('/auth/logout', response_model=AcceptedResponse)
def logout(payload: LogoutRequest, current_user: User = Depends(get_current_user), access_payload: dict = Depends(get_current_access_payload)):
    try:
        refresh_payload = decode_token(payload.refreshToken, expected_type='refresh')
    except jwt.InvalidTokenError as exc:
        raise api_error(status.HTTP_401_UNAUTHORIZED, 'invalid_refresh_token', 'Invalid or expired refresh token') from exc
    if refresh_payload.get('sub') != current_user.id:
        raise api_error(status.HTTP_401_UNAUTHORIZED, 'token_subject_mismatch', 'Refresh token does not belong to current user')
    if not is_token_revoked(refresh_payload.get('jti')):
        revoke_token(refresh_payload['jti'], refresh_payload['exp'])
    if not is_token_revoked(access_payload.get('jti')):
        revoke_token(access_payload['jti'], access_payload['exp'])
    if refresh_payload.get('family_id'):
        revoke_family(refresh_payload['family_id'], refresh_payload['exp'])
    return AcceptedResponse(accepted=True)


@router.get('/auth/me', response_model=UserProfileOut)
def auth_me(user: User = Depends(get_current_user)):
    return user_to_profile(user)
