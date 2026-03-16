from fastapi import APIRouter

from app.api.auth import router as auth_router
from app.api.notifications import router as notifications_router
from app.api.places import router as places_router
from app.api.user import router as user_router


router = APIRouter()
router.include_router(auth_router)
router.include_router(places_router)
router.include_router(user_router)
router.include_router(notifications_router)