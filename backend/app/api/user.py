from __future__ import annotations

from fastapi import APIRouter, Depends, status
from sqlalchemy import func, select
from sqlalchemy.orm import Session, selectinload

from app.api.deps import get_current_user
from app.api.utils import collection_to_detail, favorite_ids_for_user, place_to_summary, user_to_profile
from app.core.errors import api_error
from app.db.models import Collection, CollectionPlace, Favorite, Place, Review, SearchHistory, User
from app.db.session import get_db
from app.schemas.common import CollectionDetailOut, CollectionOut, CollectionsResponse, CreateCollectionRequest, CreateSearchHistoryRequest, FavoriteStatusOut, PlaceListResponse, SearchHistoryEntryOut, SearchHistoryResponse, UpdateUserRequest, UserProfileOut, UserStatsOut


router = APIRouter(tags=['User'])


@router.get('/user', response_model=UserProfileOut)
def get_user_profile(user: User = Depends(get_current_user)):
    return user_to_profile(user)


@router.put('/user', response_model=UserProfileOut)
def update_user_profile(payload: UpdateUserRequest, db: Session = Depends(get_db), user: User = Depends(get_current_user)):
    if payload.name is not None:
        user.name = payload.name
    if payload.email is not None:
        duplicate = db.scalar(select(User).where(User.email == payload.email, User.id != user.id))
        if duplicate is not None:
            raise api_error(status.HTTP_400_BAD_REQUEST, 'email_taken', 'User with this email already exists')
        user.email = payload.email
    if payload.avatar_url is not None:
        user.avatar_url = payload.avatar_url
    if payload.preferences is not None:
        if payload.preferences.company_type is not None:
            user.company_type = payload.preferences.company_type
        if payload.preferences.favorite_categories is not None:
            user.favorite_categories = payload.preferences.favorite_categories
        if payload.preferences.budget is not None:
            user.budget = payload.preferences.budget
    db.add(user)
    db.commit()
    db.refresh(user)
    return user_to_profile(user)


@router.get('/user/stats', response_model=UserStatsOut)
def get_user_stats(db: Session = Depends(get_db), user: User = Depends(get_current_user)):
    favorites_count = db.scalar(select(func.count()).select_from(Favorite).where(Favorite.user_id == user.id)) or 0
    reviews_count = db.scalar(select(func.count()).select_from(Review).where(Review.user_id == user.id)) or 0
    places_visited = db.scalar(select(func.count()).select_from(CollectionPlace).join(Collection).where(Collection.user_id == user.id)) or 0
    return UserStatsOut(places_visited=places_visited, reviews_count=reviews_count, favorites_count=favorites_count)


@router.get('/user/favorites', response_model=PlaceListResponse, tags=['Favorites'])
def list_favorites(limit: int = 20, offset: int = 0, db: Session = Depends(get_db), user: User = Depends(get_current_user)):
    places = db.scalars(select(Place).join(Favorite).where(Favorite.user_id == user.id)).all()
    favorite_ids = favorite_ids_for_user(db, user)
    page = places[offset : offset + limit]
    return PlaceListResponse(items=[place_to_summary(place, favorite_ids) for place in page], total=len(places), limit=limit, offset=offset)


@router.get('/user/favorites/{placeId}', response_model=FavoriteStatusOut, tags=['Favorites'])
def get_favorite_status(placeId: str, db: Session = Depends(get_db), user: User = Depends(get_current_user)):
    exists = db.get(Favorite, {'user_id': user.id, 'place_id': placeId}) is not None
    return FavoriteStatusOut(place_id=placeId, is_favorite=exists)


@router.post('/user/favorites/{placeId}', response_model=FavoriteStatusOut, status_code=status.HTTP_201_CREATED, tags=['Favorites'])
def add_favorite(placeId: str, db: Session = Depends(get_db), user: User = Depends(get_current_user)):
    place = db.get(Place, placeId)
    if place is None:
        raise api_error(status.HTTP_404_NOT_FOUND, 'place_not_found', 'Place not found')
    if db.get(Favorite, {'user_id': user.id, 'place_id': placeId}) is None:
        db.add(Favorite(user_id=user.id, place_id=placeId))
        db.commit()
    return FavoriteStatusOut(place_id=placeId, is_favorite=True)


@router.delete('/user/favorites/{placeId}', response_model=FavoriteStatusOut, tags=['Favorites'])
def remove_favorite(placeId: str, db: Session = Depends(get_db), user: User = Depends(get_current_user)):
    link = db.get(Favorite, {'user_id': user.id, 'place_id': placeId})
    if link is None:
        raise api_error(status.HTTP_404_NOT_FOUND, 'favorite_not_found', 'Favorite not found')
    db.delete(link)
    db.commit()
    return FavoriteStatusOut(place_id=placeId, is_favorite=False)


@router.get('/user/collections', response_model=CollectionsResponse, tags=['Collections'])
def list_collections(db: Session = Depends(get_db), user: User = Depends(get_current_user)):
    collections = db.scalars(select(Collection).where(Collection.user_id == user.id).options(selectinload(Collection.place_links))).all()
    items = [CollectionOut(id=item.id, name=item.name, place_count=len(item.place_links), created_at=item.created_at) for item in collections]
    return CollectionsResponse(items=items)


@router.post('/user/collections', response_model=CollectionOut, status_code=status.HTTP_201_CREATED, tags=['Collections'])
def create_collection(payload: CreateCollectionRequest, db: Session = Depends(get_db), user: User = Depends(get_current_user)):
    collection = Collection(user_id=user.id, name=payload.name)
    db.add(collection)
    db.commit()
    db.refresh(collection)
    return CollectionOut(id=collection.id, name=collection.name, place_count=0, created_at=collection.created_at)


@router.get('/user/collections/{collectionId}', response_model=CollectionDetailOut, tags=['Collections'])
def get_collection(collectionId: str, db: Session = Depends(get_db), user: User = Depends(get_current_user)):
    collection = db.scalar(select(Collection).where(Collection.id == collectionId, Collection.user_id == user.id).options(selectinload(Collection.place_links).selectinload(CollectionPlace.place)))
    if collection is None:
        raise api_error(status.HTTP_404_NOT_FOUND, 'collection_not_found', 'Collection not found')
    return collection_to_detail(collection, favorite_ids_for_user(db, user))


@router.delete('/user/collections/{collectionId}', status_code=status.HTTP_204_NO_CONTENT, tags=['Collections'])
def delete_collection(collectionId: str, db: Session = Depends(get_db), user: User = Depends(get_current_user)):
    collection = db.scalar(select(Collection).where(Collection.id == collectionId, Collection.user_id == user.id))
    if collection is None:
        raise api_error(status.HTTP_404_NOT_FOUND, 'collection_not_found', 'Collection not found')
    db.delete(collection)
    db.commit()


@router.post('/user/collections/{collectionId}/places/{placeId}', response_model=CollectionDetailOut, status_code=status.HTTP_201_CREATED, tags=['Collections'])
def add_place_to_collection(collectionId: str, placeId: str, db: Session = Depends(get_db), user: User = Depends(get_current_user)):
    collection = db.scalar(select(Collection).where(Collection.id == collectionId, Collection.user_id == user.id).options(selectinload(Collection.place_links).selectinload(CollectionPlace.place)))
    if collection is None:
        raise api_error(status.HTTP_404_NOT_FOUND, 'collection_not_found', 'Collection not found')
    if db.get(Place, placeId) is None:
        raise api_error(status.HTTP_404_NOT_FOUND, 'place_not_found', 'Place not found')
    if db.get(CollectionPlace, {'collection_id': collectionId, 'place_id': placeId}) is None:
        db.add(CollectionPlace(collection_id=collectionId, place_id=placeId))
        db.commit()
    collection = db.scalar(select(Collection).where(Collection.id == collectionId, Collection.user_id == user.id).options(selectinload(Collection.place_links).selectinload(CollectionPlace.place)))
    return collection_to_detail(collection, favorite_ids_for_user(db, user))


@router.delete('/user/collections/{collectionId}/places/{placeId}', response_model=CollectionDetailOut, tags=['Collections'])
def remove_place_from_collection(collectionId: str, placeId: str, db: Session = Depends(get_db), user: User = Depends(get_current_user)):
    link = db.get(CollectionPlace, {'collection_id': collectionId, 'place_id': placeId})
    if link is None:
        raise api_error(status.HTTP_404_NOT_FOUND, 'collection_place_not_found', 'Collection place not found')
    db.delete(link)
    db.commit()
    collection = db.scalar(select(Collection).where(Collection.id == collectionId, Collection.user_id == user.id).options(selectinload(Collection.place_links).selectinload(CollectionPlace.place)))
    if collection is None:
        raise api_error(status.HTTP_404_NOT_FOUND, 'collection_not_found', 'Collection not found')
    return collection_to_detail(collection, favorite_ids_for_user(db, user))


@router.get('/user/search-history', response_model=SearchHistoryResponse)
def list_search_history(db: Session = Depends(get_db), user: User = Depends(get_current_user)):
    items = db.scalars(select(SearchHistory).where(SearchHistory.user_id == user.id).order_by(SearchHistory.created_at.desc())).all()
    return SearchHistoryResponse(items=[SearchHistoryEntryOut(id=item.id, query=item.query, filters=item.filters, created_at=item.created_at) for item in items])


@router.post('/user/search-history', response_model=SearchHistoryEntryOut, status_code=status.HTTP_201_CREATED)
def create_search_history(payload: CreateSearchHistoryRequest, db: Session = Depends(get_db), user: User = Depends(get_current_user)):
    filters = payload.filters.model_dump() if hasattr(payload.filters, 'model_dump') else payload.filters
    entry = SearchHistory(user_id=user.id, query=payload.query, filters=filters)
    db.add(entry)
    db.commit()
    db.refresh(entry)
    return SearchHistoryEntryOut(id=entry.id, query=entry.query, filters=entry.filters, created_at=entry.created_at)


@router.delete('/user/search-history/{entryId}', status_code=status.HTTP_204_NO_CONTENT)
def delete_search_history(entryId: str, db: Session = Depends(get_db), user: User = Depends(get_current_user)):
    entry = db.scalar(select(SearchHistory).where(SearchHistory.id == entryId, SearchHistory.user_id == user.id))
    if entry is None:
        raise api_error(status.HTTP_404_NOT_FOUND, 'search_history_not_found', 'Search history entry not found')
    db.delete(entry)
    db.commit()


@router.delete('/user/reviews/{reviewId}', status_code=status.HTTP_204_NO_CONTENT, tags=['Reviews'])
def delete_review(reviewId: str, db: Session = Depends(get_db), user: User = Depends(get_current_user)):
    review = db.scalar(select(Review).where(Review.id == reviewId, Review.user_id == user.id))
    if review is None:
        raise api_error(status.HTTP_404_NOT_FOUND, 'review_not_found', 'Review not found')
    place = db.get(Place, review.place_id)
    db.delete(review)
    db.commit()
    if place is not None:
        remaining_reviews = db.scalars(select(Review).where(Review.place_id == place.id)).all()
        if remaining_reviews:
            place.review_count = len(remaining_reviews)
            place.rating = round(sum(item.rating for item in remaining_reviews) / len(remaining_reviews), 1)
        else:
            place.review_count = 0
            place.rating = 0
        db.add(place)
        db.commit()
