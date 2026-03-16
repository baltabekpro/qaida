from __future__ import annotations

from fastapi import APIRouter, Depends, Query, status
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.api.deps import get_current_user
from app.core.errors import api_error
from app.db.models import Notification, NotificationType, User
from app.db.session import get_db
from app.schemas.common import NotificationListResponse, NotificationOut, NotificationPreferencesOut, NotificationPreferencesUpdate, NotificationSubscribeRequest, UpdateNotificationRequest


router = APIRouter(tags=['Notifications'])


@router.get('/user/notifications', response_model=NotificationListResponse)
def list_notifications(type: list[NotificationType] | None = Query(default=None), read: bool | None = None, limit: int = 20, offset: int = 0, db: Session = Depends(get_db), user: User = Depends(get_current_user)):
    stmt = select(Notification).where(Notification.user_id == user.id).order_by(Notification.created_at.desc())
    if type:
        stmt = stmt.where(Notification.type.in_(type))
    if read is not None:
        stmt = stmt.where(Notification.read == read)
    items = db.scalars(stmt).all()
    page = items[offset : offset + limit]
    unread_count = sum(1 for item in items if not item.read)
    return NotificationListResponse(items=[NotificationOut.model_validate(item) for item in page], unread_count=unread_count, total=len(items))


@router.patch('/user/notifications/{notificationId}', response_model=NotificationOut)
def update_notification(notificationId: str, payload: UpdateNotificationRequest, db: Session = Depends(get_db), user: User = Depends(get_current_user)):
    notification = db.scalar(select(Notification).where(Notification.id == notificationId, Notification.user_id == user.id))
    if notification is None:
        raise api_error(status.HTTP_404_NOT_FOUND, 'notification_not_found', 'Notification not found')
    notification.read = payload.read
    db.add(notification)
    db.commit()
    db.refresh(notification)
    return NotificationOut.model_validate(notification)


@router.delete('/user/notifications/{notificationId}', status_code=status.HTTP_204_NO_CONTENT)
def delete_notification(notificationId: str, db: Session = Depends(get_db), user: User = Depends(get_current_user)):
    notification = db.scalar(select(Notification).where(Notification.id == notificationId, Notification.user_id == user.id))
    if notification is None:
        raise api_error(status.HTTP_404_NOT_FOUND, 'notification_not_found', 'Notification not found')
    db.delete(notification)
    db.commit()


@router.get('/user/notification-preferences', response_model=NotificationPreferencesOut)
def get_notification_preferences(user: User = Depends(get_current_user)):
    return NotificationPreferencesOut(enabled=user.notifications_enabled, enabled_types=user.enabled_notification_types)


@router.post('/user/notification-preferences', response_model=NotificationPreferencesOut)
def update_notification_preferences(payload: NotificationPreferencesUpdate, db: Session = Depends(get_db), user: User = Depends(get_current_user)):
    user.notifications_enabled = payload.enabled
    user.enabled_notification_types = [item.value if hasattr(item, 'value') else item for item in payload.enabled_types]
    db.add(user)
    db.commit()
    db.refresh(user)
    return NotificationPreferencesOut(enabled=user.notifications_enabled, enabled_types=user.enabled_notification_types)


@router.post('/user/notification-preferences/subscribe', response_model=NotificationPreferencesOut)
def subscribe_notifications(payload: NotificationSubscribeRequest, db: Session = Depends(get_db), user: User = Depends(get_current_user)):
    del payload
    user.notifications_enabled = True
    if not user.enabled_notification_types:
        user.enabled_notification_types = [item.value for item in NotificationType]
    db.add(user)
    db.commit()
    db.refresh(user)
    return NotificationPreferencesOut(enabled=user.notifications_enabled, enabled_types=user.enabled_notification_types)
