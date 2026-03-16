from __future__ import annotations

from datetime import datetime
from enum import Enum
from uuid import uuid4

from sqlalchemy import Boolean, DateTime, Enum as SqlEnum, Float, ForeignKey, Integer, JSON, String, Text
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column, relationship


class CompanyType(str, Enum):
    SOLO = 'solo'
    COUPLE = 'couple'
    FRIENDS = 'friends'
    FAMILY = 'family'


class BudgetRange(str, Enum):
    LOW = '$'
    MEDIUM = '$$'
    HIGH = '$$$'


class PlaceStatus(str, Enum):
    OPEN = 'open'
    CLOSED = 'closed'
    COMING_SOON = 'coming_soon'


class NotificationType(str, Enum):
    NEW_PLACE = 'new_place'
    REMINDER = 'reminder'
    SAVED_PLACE = 'saved_place'
    RECOMMENDATION = 'recommendation'
    BOOKING = 'booking'


class Base(DeclarativeBase):
    pass


def generate_id() -> str:
    return str(uuid4())


class TimestampMixin:
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, nullable=False)


class User(Base):
    __tablename__ = 'users'

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=generate_id)
    name: Mapped[str] = mapped_column(String(120), nullable=False)
    email: Mapped[str] = mapped_column(String(255), unique=True, nullable=False, index=True)
    password_hash: Mapped[str] = mapped_column(String(255), nullable=False)
    avatar_url: Mapped[str | None] = mapped_column(String(500))
    is_active: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    company_type: Mapped[CompanyType] = mapped_column(SqlEnum(CompanyType), default=CompanyType.FRIENDS, nullable=False)
    favorite_categories: Mapped[list[str]] = mapped_column(JSON, default=list, nullable=False)
    budget: Mapped[BudgetRange] = mapped_column(SqlEnum(BudgetRange), default=BudgetRange.MEDIUM, nullable=False)
    notifications_enabled: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    enabled_notification_types: Mapped[list[str]] = mapped_column(JSON, default=list, nullable=False)

    favorites: Mapped[list[Favorite]] = relationship(back_populates='user', cascade='all, delete-orphan')
    collections: Mapped[list[Collection]] = relationship(back_populates='user', cascade='all, delete-orphan')
    reviews: Mapped[list[Review]] = relationship(back_populates='user', cascade='all, delete-orphan')
    notifications: Mapped[list[Notification]] = relationship(back_populates='user', cascade='all, delete-orphan')
    search_history: Mapped[list[SearchHistory]] = relationship(back_populates='user', cascade='all, delete-orphan')


class Place(Base):
    __tablename__ = 'places'

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=generate_id)
    name: Mapped[str] = mapped_column(String(255), nullable=False, index=True)
    category: Mapped[str] = mapped_column(String(120), nullable=False, index=True)
    short_description: Mapped[str] = mapped_column(String(255), nullable=False)
    description: Mapped[str] = mapped_column(Text, nullable=False)
    rating: Mapped[float] = mapped_column(Float, default=0, nullable=False)
    review_count: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    address: Mapped[str] = mapped_column(String(255), nullable=False)
    budget: Mapped[BudgetRange] = mapped_column(SqlEnum(BudgetRange), default=BudgetRange.MEDIUM, nullable=False)
    status: Mapped[PlaceStatus] = mapped_column(SqlEnum(PlaceStatus), default=PlaceStatus.OPEN, nullable=False)
    image_url: Mapped[str | None] = mapped_column(String(500))
    tags: Mapped[list[str]] = mapped_column(JSON, default=list, nullable=False)
    amenities: Mapped[list[str]] = mapped_column(JSON, default=list, nullable=False)
    gallery: Mapped[list[str]] = mapped_column(JSON, default=list, nullable=False)
    latitude: Mapped[float] = mapped_column(Float, nullable=False)
    longitude: Mapped[float] = mapped_column(Float, nullable=False)
    popularity_score: Mapped[int] = mapped_column(Integer, default=0, nullable=False)

    opening_hours: Mapped[list[OpeningHour]] = relationship(back_populates='place', cascade='all, delete-orphan')
    menu_items: Mapped[list[MenuItem]] = relationship(back_populates='place', cascade='all, delete-orphan')
    reviews: Mapped[list[Review]] = relationship(back_populates='place', cascade='all, delete-orphan')
    favorites: Mapped[list[Favorite]] = relationship(back_populates='place', cascade='all, delete-orphan')
    collection_links: Mapped[list[CollectionPlace]] = relationship(back_populates='place', cascade='all, delete-orphan')


class OpeningHour(Base):
    __tablename__ = 'opening_hours'

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=generate_id)
    place_id: Mapped[str] = mapped_column(ForeignKey('places.id', ondelete='CASCADE'), nullable=False, index=True)
    day: Mapped[str] = mapped_column(String(16), nullable=False)
    open_time: Mapped[str] = mapped_column(String(5), nullable=False)
    close_time: Mapped[str] = mapped_column(String(5), nullable=False)

    place: Mapped[Place] = relationship(back_populates='opening_hours')


class MenuItem(Base):
    __tablename__ = 'menu_items'

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=generate_id)
    place_id: Mapped[str] = mapped_column(ForeignKey('places.id', ondelete='CASCADE'), nullable=False, index=True)
    name: Mapped[str] = mapped_column(String(255), nullable=False)
    description: Mapped[str | None] = mapped_column(Text)
    category: Mapped[str] = mapped_column(String(80), nullable=False)
    price: Mapped[float] = mapped_column(Float, nullable=False)
    currency: Mapped[str] = mapped_column(String(8), default='KZT', nullable=False)
    image_url: Mapped[str | None] = mapped_column(String(500))

    place: Mapped[Place] = relationship(back_populates='menu_items')


class Review(Base, TimestampMixin):
    __tablename__ = 'reviews'

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=generate_id)
    place_id: Mapped[str] = mapped_column(ForeignKey('places.id', ondelete='CASCADE'), nullable=False, index=True)
    user_id: Mapped[str] = mapped_column(ForeignKey('users.id', ondelete='CASCADE'), nullable=False, index=True)
    rating: Mapped[int] = mapped_column(Integer, nullable=False)
    text: Mapped[str] = mapped_column(Text, nullable=False)

    place: Mapped[Place] = relationship(back_populates='reviews')
    user: Mapped[User] = relationship(back_populates='reviews')


class Favorite(Base, TimestampMixin):
    __tablename__ = 'favorites'

    user_id: Mapped[str] = mapped_column(ForeignKey('users.id', ondelete='CASCADE'), primary_key=True)
    place_id: Mapped[str] = mapped_column(ForeignKey('places.id', ondelete='CASCADE'), primary_key=True)

    user: Mapped[User] = relationship(back_populates='favorites')
    place: Mapped[Place] = relationship(back_populates='favorites')


class Collection(Base, TimestampMixin):
    __tablename__ = 'collections'

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=generate_id)
    user_id: Mapped[str] = mapped_column(ForeignKey('users.id', ondelete='CASCADE'), nullable=False, index=True)
    name: Mapped[str] = mapped_column(String(120), nullable=False)

    user: Mapped[User] = relationship(back_populates='collections')
    place_links: Mapped[list[CollectionPlace]] = relationship(back_populates='collection', cascade='all, delete-orphan')


class CollectionPlace(Base):
    __tablename__ = 'collection_places'

    collection_id: Mapped[str] = mapped_column(ForeignKey('collections.id', ondelete='CASCADE'), primary_key=True)
    place_id: Mapped[str] = mapped_column(ForeignKey('places.id', ondelete='CASCADE'), primary_key=True)

    collection: Mapped[Collection] = relationship(back_populates='place_links')
    place: Mapped[Place] = relationship(back_populates='collection_links')


class Notification(Base, TimestampMixin):
    __tablename__ = 'notifications'

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=generate_id)
    user_id: Mapped[str] = mapped_column(ForeignKey('users.id', ondelete='CASCADE'), nullable=False, index=True)
    type: Mapped[NotificationType] = mapped_column(SqlEnum(NotificationType), nullable=False)
    title: Mapped[str] = mapped_column(String(160), nullable=False)
    message: Mapped[str] = mapped_column(Text, nullable=False)
    action_url: Mapped[str | None] = mapped_column(String(500))
    read: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)

    user: Mapped[User] = relationship(back_populates='notifications')


class SearchHistory(Base, TimestampMixin):
    __tablename__ = 'search_history'

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=generate_id)
    user_id: Mapped[str] = mapped_column(ForeignKey('users.id', ondelete='CASCADE'), nullable=False, index=True)
    query: Mapped[str] = mapped_column(String(255), nullable=False)
    filters: Mapped[dict] = mapped_column(JSON, default=dict, nullable=False)

    user: Mapped[User] = relationship(back_populates='search_history')
