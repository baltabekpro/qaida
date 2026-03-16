from __future__ import annotations

from fastapi import APIRouter, Depends, Query, status
from sqlalchemy import or_, select
from sqlalchemy.orm import Session, selectinload

from app.api.deps import get_current_user, get_optional_current_user
from app.api.utils import compute_match_score, favorite_ids_for_user, filter_places, geo_distance_km, place_to_detail, place_to_summary, refresh_place_rating, review_to_out
from app.core.errors import api_error
from app.db.models import MenuItem, Place, Review, User
from app.db.session import get_db
from app.schemas.common import AcceptedResponse, CategoriesResponse, CategoryOut, CreateComplaintRequest, CreateRecommendationRequest, CreateReviewRequest, MenuItemOut, MenuItemsResponse, PlaceDetailOut, PlaceListResponse, RecommendationListResponse, RecommendationOut, ReviewListResponse, ReviewOut, SearchResponse, ShareResponse
from app.services.cache import get_json, set_json


router = APIRouter(tags=['Places'])

CATEGORY_ICONS = {
    'Кафе': 'local_cafe',
    'Ресторан': 'restaurant',
    'Бар': 'local_bar',
    'Парк': 'park',
    'Кино': 'movie',
}


@router.get('/places', response_model=PlaceListResponse)
def list_places(category: list[str] | None = Query(default=None), budget: str | None = Query(default=None), companyType: str | None = Query(default=None), distanceKm: float | None = Query(default=None), sortBy: str = Query(default='popularity'), lat: float | None = None, lng: float | None = None, limit: int = 20, offset: int = 0, db: Session = Depends(get_db), user: User | None = Depends(get_optional_current_user)):
    places = db.scalars(select(Place).options(selectinload(Place.opening_hours), selectinload(Place.menu_items))).all()
    places = filter_places(places, category, budget, companyType)
    if lat is not None and lng is not None and distanceKm is not None:
        places = [item for item in places if geo_distance_km(lat, lng, item.latitude, item.longitude) <= distanceKm]
    if sortBy == 'rating':
        places.sort(key=lambda item: item.rating, reverse=True)
    elif sortBy == 'distance' and lat is not None and lng is not None:
        places.sort(key=lambda item: geo_distance_km(lat, lng, item.latitude, item.longitude))
    else:
        places.sort(key=lambda item: item.popularity_score, reverse=True)
    favorite_ids = favorite_ids_for_user(db, user)
    page = places[offset : offset + limit]
    return PlaceListResponse(items=[place_to_summary(place, favorite_ids, lat, lng) for place in page], total=len(places), limit=limit, offset=offset)


@router.get('/places/popular', response_model=PlaceListResponse)
def popular_places(limit: int = 10, db: Session = Depends(get_db), user: User | None = Depends(get_optional_current_user)):
    cache_key = f'popular_places:{user.id if user else "anon"}:{limit}'
    cached = get_json(cache_key)
    if cached:
        return cached
    favorite_ids = favorite_ids_for_user(db, user)
    places = db.scalars(select(Place).order_by(Place.popularity_score.desc()).limit(limit)).all()
    payload = PlaceListResponse(items=[place_to_summary(place, favorite_ids) for place in places], total=len(places), limit=limit, offset=0).model_dump(mode='json', by_alias=True)
    set_json(cache_key, payload, ttl=120)
    return payload


@router.get('/places/nearby', response_model=PlaceListResponse)
def nearby_places(lat: float, lng: float, distanceKm: float = Query(default=5), limit: int = 20, db: Session = Depends(get_db), user: User | None = Depends(get_optional_current_user)):
    places = db.scalars(select(Place)).all()
    places = [place for place in places if geo_distance_km(lat, lng, place.latitude, place.longitude) <= distanceKm]
    places.sort(key=lambda place: geo_distance_km(lat, lng, place.latitude, place.longitude))
    favorite_ids = favorite_ids_for_user(db, user)
    page = places[:limit]
    return PlaceListResponse(items=[place_to_summary(place, favorite_ids, lat, lng) for place in page], total=len(places), limit=limit, offset=0)


@router.get('/places/{placeId}', response_model=PlaceDetailOut)
def get_place(placeId: str, db: Session = Depends(get_db), user: User | None = Depends(get_optional_current_user)):
    place = db.scalar(select(Place).where(Place.id == placeId).options(selectinload(Place.opening_hours), selectinload(Place.menu_items)))
    if place is None:
        raise api_error(status.HTTP_404_NOT_FOUND, 'place_not_found', 'Place not found')
    return place_to_detail(place, favorite_ids_for_user(db, user))


@router.get('/places/{placeId}/menu', response_model=MenuItemsResponse)
def get_place_menu(placeId: str, category: str | None = None, db: Session = Depends(get_db)):
    place = db.get(Place, placeId)
    if place is None:
        raise api_error(status.HTTP_404_NOT_FOUND, 'place_not_found', 'Place not found')
    stmt = select(MenuItem).where(MenuItem.place_id == placeId)
    if category:
        stmt = stmt.where(MenuItem.category == category)
    items = db.scalars(stmt).all()
    return MenuItemsResponse(items=[MenuItemOut.model_validate(item) for item in items])


@router.get('/places/{placeId}/reviews', response_model=ReviewListResponse, tags=['Reviews'])
def get_place_reviews(placeId: str, limit: int = 20, offset: int = 0, db: Session = Depends(get_db)):
    place = db.get(Place, placeId)
    if place is None:
        raise api_error(status.HTTP_404_NOT_FOUND, 'place_not_found', 'Place not found')
    reviews = db.scalars(select(Review).where(Review.place_id == placeId).options(selectinload(Review.user)).order_by(Review.created_at.desc())).all()
    page = reviews[offset : offset + limit]
    return ReviewListResponse(items=[review_to_out(item) for item in page], total=len(reviews), limit=limit, offset=offset)


@router.post('/places/{placeId}/reviews', response_model=ReviewOut, status_code=status.HTTP_201_CREATED, tags=['Reviews'])
def create_review(placeId: str, payload: CreateReviewRequest, db: Session = Depends(get_db), user: User = Depends(get_current_user)):
    place = db.get(Place, placeId)
    if place is None:
        raise api_error(status.HTTP_404_NOT_FOUND, 'place_not_found', 'Place not found')
    review = Review(place_id=placeId, user_id=user.id, rating=payload.rating, text=payload.text)
    db.add(review)
    db.commit()
    review = db.scalar(select(Review).where(Review.id == review.id).options(selectinload(Review.user)))
    refresh_place_rating(db, placeId)
    return review_to_out(review)


@router.post('/places/{placeId}/share', response_model=ShareResponse)
def share_place(placeId: str, db: Session = Depends(get_db)):
    place = db.get(Place, placeId)
    if place is None:
        raise api_error(status.HTTP_404_NOT_FOUND, 'place_not_found', 'Place not found')
    return ShareResponse(share_url=f'https://qaida.app/places/{place.id}')


@router.post('/places/{placeId}/complaints', response_model=AcceptedResponse, status_code=status.HTTP_202_ACCEPTED)
def create_complaint(placeId: str, payload: CreateComplaintRequest, db: Session = Depends(get_db), user: User = Depends(get_current_user)):
    del payload
    place = db.get(Place, placeId)
    if place is None:
        raise api_error(status.HTTP_404_NOT_FOUND, 'place_not_found', 'Place not found')
    return AcceptedResponse(accepted=True)


@router.get('/search', response_model=SearchResponse, tags=['Search'])
def search_places(query: str, category: list[str] | None = Query(default=None), budget: str | None = Query(default=None), companyType: str | None = Query(default=None), distanceKm: float | None = Query(default=None), sortBy: str = Query(default='popularity'), lat: float | None = None, lng: float | None = None, limit: int = 20, offset: int = 0, db: Session = Depends(get_db), user: User | None = Depends(get_optional_current_user)):
    places = db.scalars(select(Place).where(or_(Place.name.ilike(f'%{query}%'), Place.category.ilike(f'%{query}%'), Place.description.ilike(f'%{query}%')))).all()
    places = filter_places(places, category, budget, companyType)
    if lat is not None and lng is not None and distanceKm is not None:
        places = [place for place in places if geo_distance_km(lat, lng, place.latitude, place.longitude) <= distanceKm]
    if sortBy == 'rating':
        places.sort(key=lambda item: item.rating, reverse=True)
    elif sortBy == 'distance' and lat is not None and lng is not None:
        places.sort(key=lambda item: geo_distance_km(lat, lng, item.latitude, item.longitude))
    favorite_ids = favorite_ids_for_user(db, user)
    page = places[offset : offset + limit]
    items = []
    for place in page:
        score, reasons = compute_match_score(place, companyType, category, budget, query)
        items.append(RecommendationOut(place=place_to_summary(place, favorite_ids, lat, lng), match_score=score, reasons=reasons))
    return SearchResponse(items=items, total=len(places))


@router.get('/recommendations', response_model=RecommendationListResponse, tags=['Recommendations'])
def get_recommendations(companyType: str | None = Query(default=None), category: list[str] | None = Query(default=None), budget: str | None = Query(default=None), lat: float | None = None, lng: float | None = None, limit: int = 10, db: Session = Depends(get_db), user: User | None = Depends(get_optional_current_user)):
    if user is not None:
        effective_company_type = companyType or user.company_type.value
        effective_categories = category or user.favorite_categories
        effective_budget = budget or user.budget.value
    else:
        effective_company_type = companyType
        effective_categories = category
        effective_budget = budget
    places = filter_places(db.scalars(select(Place)).all(), effective_categories, effective_budget, effective_company_type)
    places.sort(key=lambda place: compute_match_score(place, effective_company_type, effective_categories, effective_budget, None)[0], reverse=True)
    favorite_ids = favorite_ids_for_user(db, user)
    items = []
    for place in places[:limit]:
        score, reasons = compute_match_score(place, effective_company_type, effective_categories, effective_budget, None)
        items.append(RecommendationOut(place=place_to_summary(place, favorite_ids, lat, lng), match_score=score, reasons=reasons))
    return RecommendationListResponse(items=items)


@router.post('/recommendations', response_model=RecommendationListResponse, tags=['Recommendations'])
def create_recommendations(payload: CreateRecommendationRequest, db: Session = Depends(get_db), user: User | None = Depends(get_optional_current_user)):
    lat = payload.coordinates.lat if payload.coordinates else None
    lng = payload.coordinates.lng if payload.coordinates else None
    places = filter_places(db.scalars(select(Place)).all(), payload.categories or None, payload.budget.value if payload.budget else None, payload.company_type.value)
    places.sort(key=lambda place: compute_match_score(place, payload.company_type.value, payload.categories, payload.budget.value if payload.budget else None, None)[0], reverse=True)
    favorite_ids = favorite_ids_for_user(db, user)
    items = []
    for place in places[:10]:
        score, reasons = compute_match_score(place, payload.company_type.value, payload.categories, payload.budget.value if payload.budget else None, None)
        items.append(RecommendationOut(place=place_to_summary(place, favorite_ids, lat, lng), match_score=score, reasons=reasons))
    return RecommendationListResponse(items=items)


@router.get('/categories', response_model=CategoriesResponse, tags=['Meta'])
def list_categories(db: Session = Depends(get_db)):
    cached = get_json('categories')
    if cached:
        return cached
    rows = db.scalars(select(Place.category).distinct().order_by(Place.category.asc())).all()
    items = [CategoryOut(id=item.lower().replace(' ', '-'), slug=item.lower().replace(' ', '-'), name=item, icon=CATEGORY_ICONS.get(item)) for item in rows]
    payload = CategoriesResponse(items=items).model_dump(mode='json', by_alias=True)
    set_json('categories', payload, ttl=3600)
    return payload
