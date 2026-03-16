from __future__ import annotations

from math import sqrt

from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.db.models import Collection, Favorite, Place, Review, User
from app.schemas.common import CollectionDetailOut, MenuItemOut, NotificationPreferencesOut, PlaceDetailOut, PlaceSummaryOut, ReviewOut, UserPreferencesOut, UserProfileOut


def geo_distance_km(lat1: float, lng1: float, lat2: float, lng2: float) -> float:
    return round(sqrt((lat1 - lat2) ** 2 + (lng1 - lng2) ** 2) * 111, 2)


def favorite_ids_for_user(db: Session, user: User | None) -> set[str]:
    if user is None:
        return set()
    place_ids = db.scalars(select(Favorite.place_id).where(Favorite.user_id == user.id)).all()
    return set(place_ids)


def place_to_summary(place: Place, favorite_ids: set[str], lat: float | None = None, lng: float | None = None) -> PlaceSummaryOut:
    distance_km = geo_distance_km(lat, lng, place.latitude, place.longitude) if lat is not None and lng is not None else None
    return PlaceSummaryOut(
        id=place.id,
        name=place.name,
        category=place.category,
        short_description=place.short_description,
        rating=round(place.rating, 1),
        review_count=place.review_count,
        address=place.address,
        distance_km=distance_km,
        budget=place.budget,
        status=place.status,
        image_url=place.image_url,
        tags=place.tags,
        is_favorite=place.id in favorite_ids,
    )


def place_to_detail(place: Place, favorite_ids: set[str], lat: float | None = None, lng: float | None = None) -> PlaceDetailOut:
    return PlaceDetailOut(
        **place_to_summary(place, favorite_ids, lat, lng).model_dump(),
        description=place.description,
        coordinates={'lat': place.latitude, 'lng': place.longitude},
        opening_hours=[{'day': row.day, 'open': row.open_time, 'close': row.close_time} for row in place.opening_hours],
        gallery=place.gallery,
        amenities=place.amenities,
        menu_preview=[MenuItemOut.model_validate(item) for item in place.menu_items[:3]],
    )


def review_to_out(review: Review) -> ReviewOut:
    return ReviewOut(
        id=review.id,
        place_id=review.place_id,
        user_id=review.user_id,
        author_name=review.user.name,
        rating=review.rating,
        text=review.text,
        created_at=review.created_at,
    )


def user_to_profile(user: User) -> UserProfileOut:
    return UserProfileOut(
        id=user.id,
        name=user.name,
        email=user.email,
        avatar_url=user.avatar_url,
        preferences=UserPreferencesOut(
            company_type=user.company_type,
            favorite_categories=user.favorite_categories,
            budget=user.budget,
        ),
        notification_preferences=NotificationPreferencesOut(
            enabled=user.notifications_enabled,
            enabled_types=user.enabled_notification_types,
        ),
    )


def compute_match_score(place: Place, company_type: str | None, categories: list[str] | None, budget: str | None, query: str | None) -> tuple[int, list[str]]:
    score = 68
    reasons: list[str] = []
    if company_type and company_type in place.tags:
        score += 12
        reasons.append('Подходит под выбранный формат компании')
    if categories and place.category in categories:
        score += 10
        reasons.append('Совпадает с выбранной категорией')
    if budget and place.budget.value == budget:
        score += 6
        reasons.append('Подходит по бюджету')
    if query and query.lower() in f'{place.name} {place.category} {place.description}'.lower():
        score += 8
        reasons.append('Совпадает с поисковым запросом')
    score += min(place.popularity_score // 12, 8)
    if not reasons:
        reasons.append('Популярное место рядом с пользователем')
    return min(score, 100), reasons


def filter_places(places: list[Place], category: list[str] | None, budget: str | None, company_type: str | None) -> list[Place]:
    result = places
    if category:
        allowed = set(category)
        result = [place for place in result if place.category in allowed]
    if budget:
        result = [place for place in result if place.budget.value == budget]
    if company_type:
        result = [place for place in result if company_type in place.tags]
    return result


def collection_to_detail(collection: Collection, favorite_ids: set[str]) -> CollectionDetailOut:
    places = [place_to_summary(link.place, favorite_ids) for link in collection.place_links]
    return CollectionDetailOut(
        id=collection.id,
        name=collection.name,
        place_count=len(collection.place_links),
        created_at=collection.created_at,
        places=places,
    )


def refresh_place_rating(db: Session, place_id: str) -> None:
    avg_rating, review_count = db.execute(
        select(func.avg(Review.rating), func.count(Review.id)).where(Review.place_id == place_id)
    ).one()
    place = db.get(Place, place_id)
    if place is None:
        return
    place.rating = round(avg_rating or 0, 1)
    place.review_count = review_count or 0
    db.add(place)
    db.commit()