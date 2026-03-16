from __future__ import annotations

from datetime import datetime

from pydantic import BaseModel, ConfigDict, EmailStr, Field
from pydantic.alias_generators import to_camel

from app.db.models import BudgetRange, CompanyType, NotificationType, PlaceStatus


class APIModel(BaseModel):
    model_config = ConfigDict(alias_generator=to_camel, populate_by_name=True, from_attributes=True)


class RequestModel(BaseModel):
    model_config = ConfigDict(populate_by_name=True)


class ErrorResponse(APIModel):
    code: str
    message: str
    details: dict = Field(default_factory=dict)


class Coordinates(APIModel):
    lat: float
    lng: float


class OpeningHourOut(APIModel):
    day: str
    open: str
    close: str


class MenuItemOut(APIModel):
    id: str
    name: str
    description: str | None = None
    category: str
    price: float
    currency: str = 'KZT'
    image_url: str | None = None


class MenuItemsResponse(APIModel):
    items: list[MenuItemOut]


class PlaceSummaryOut(APIModel):
    id: str
    name: str
    category: str
    short_description: str
    rating: float
    review_count: int
    address: str
    distance_km: float | None = None
    budget: BudgetRange
    status: PlaceStatus
    image_url: str | None = None
    tags: list[str] = Field(default_factory=list)
    is_favorite: bool


class PlaceDetailOut(PlaceSummaryOut):
    description: str
    coordinates: Coordinates
    opening_hours: list[OpeningHourOut] = Field(default_factory=list)
    gallery: list[str] = Field(default_factory=list)
    amenities: list[str] = Field(default_factory=list)
    menu_preview: list[MenuItemOut] = Field(default_factory=list)


class PlaceListResponse(APIModel):
    items: list[PlaceSummaryOut]
    total: int
    limit: int
    offset: int


class ReviewOut(APIModel):
    id: str
    place_id: str
    user_id: str
    author_name: str
    rating: int
    text: str
    created_at: datetime


class ReviewListResponse(APIModel):
    items: list[ReviewOut]
    total: int
    limit: int
    offset: int


class CreateReviewRequest(APIModel):
    rating: int = Field(ge=1, le=5)
    text: str = Field(min_length=1)


class RecommendationOut(APIModel):
    place: PlaceSummaryOut
    match_score: int = Field(ge=0, le=100)
    reasons: list[str] = Field(default_factory=list)


class RecommendationListResponse(APIModel):
    items: list[RecommendationOut]


class SearchResponse(APIModel):
    items: list[RecommendationOut]
    total: int


class SearchFilters(APIModel):
    categories: list[str] = Field(default_factory=list)
    company_type: CompanyType | None = None
    budget: BudgetRange | None = None
    distance_km: float | None = None
    sort_by: str | None = None


class CreateRecommendationRequest(APIModel):
    company_type: CompanyType
    categories: list[str] = Field(default_factory=list)
    budget: BudgetRange | None = None
    coordinates: Coordinates | None = None


class UserPreferencesOut(APIModel):
    company_type: CompanyType
    favorite_categories: list[str] = Field(default_factory=list)
    budget: BudgetRange


class UserPreferencesUpdate(APIModel):
    company_type: CompanyType | None = None
    favorite_categories: list[str] | None = None
    budget: BudgetRange | None = None


class NotificationPreferencesOut(APIModel):
    enabled: bool
    enabled_types: list[NotificationType] = Field(default_factory=list)


class UserProfileOut(APIModel):
    id: str
    name: str
    email: EmailStr
    avatar_url: str | None = None
    preferences: UserPreferencesOut
    notification_preferences: NotificationPreferencesOut


class UpdateUserRequest(APIModel):
    name: str | None = None
    email: EmailStr | None = None
    avatar_url: str | None = None
    preferences: UserPreferencesUpdate | None = None


class UserStatsOut(APIModel):
    places_visited: int
    reviews_count: int
    favorites_count: int


class FavoriteStatusOut(APIModel):
    place_id: str
    is_favorite: bool


class CollectionOut(APIModel):
    id: str
    name: str
    place_count: int
    created_at: datetime


class CollectionDetailOut(CollectionOut):
    places: list[PlaceSummaryOut] = Field(default_factory=list)


class CollectionsResponse(APIModel):
    items: list[CollectionOut]


class CreateCollectionRequest(APIModel):
    name: str = Field(min_length=1, max_length=120)


class NotificationOut(APIModel):
    id: str
    type: NotificationType
    title: str
    message: str
    action_url: str | None = None
    read: bool
    created_at: datetime


class NotificationListResponse(APIModel):
    items: list[NotificationOut]
    unread_count: int
    total: int


class UpdateNotificationRequest(APIModel):
    read: bool


class SearchHistoryEntryOut(APIModel):
    id: str
    query: str
    filters: SearchFilters | dict
    created_at: datetime


class SearchHistoryResponse(APIModel):
    items: list[SearchHistoryEntryOut]


class CreateSearchHistoryRequest(APIModel):
    query: str
    filters: SearchFilters | dict = Field(default_factory=dict)


class NotificationPreferencesUpdate(APIModel):
    enabled: bool
    enabled_types: list[NotificationType] = Field(default_factory=list)


class NotificationSubscribeRequest(APIModel):
    device_token: str | None = None
    platform: str | None = None


class CategoryOut(APIModel):
    id: str
    slug: str
    name: str
    icon: str | None = None


class CategoriesResponse(APIModel):
    items: list[CategoryOut]


class CreateComplaintRequest(APIModel):
    reason: str
    description: str | None = None


class ShareResponse(APIModel):
    share_url: str


class AcceptedResponse(APIModel):
    accepted: bool = True


class AuthUserOut(APIModel):
    id: str
    name: str
    email: EmailStr


class RegisterRequest(RequestModel):
    name: str = Field(min_length=1, max_length=120)
    email: EmailStr
    password: str = Field(min_length=8, max_length=128)
    avatarUrl: str | None = None


class LoginRequest(RequestModel):
    email: EmailStr
    password: str = Field(min_length=8, max_length=128)


class RefreshTokenRequest(RequestModel):
    refreshToken: str


class LogoutRequest(RequestModel):
    refreshToken: str


class TokenResponse(APIModel):
    access_token: str
    refresh_token: str
    token_type: str = 'bearer'
    expires_in: int
    user: AuthUserOut