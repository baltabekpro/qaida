from contextlib import asynccontextmanager

from fastapi import FastAPI, HTTPException
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse

from app.api.router import router
from app.core.config import get_settings
from app.core.errors import http_exception_response, validation_exception_response
from app.db.seed import seed_database
from app.db.session import SessionLocal
from app.services.health import check_database, check_redis


@asynccontextmanager
async def lifespan(_: FastAPI):
    db = SessionLocal()
    try:
        seed_database(db)
    finally:
        db.close()
    yield


settings = get_settings()
app = FastAPI(title=settings.app_name, version='1.0.0', lifespan=lifespan)
app.include_router(router, prefix='/api/v1')
app.add_exception_handler(HTTPException, http_exception_response)
app.add_exception_handler(RequestValidationError, validation_exception_response)


@app.get('/health')
def healthcheck():
    database = check_database()
    redis = check_redis()
    status_value = 'ok' if database['status'] == 'ok' and redis['status'] == 'ok' else 'degraded'
    return {'status': status_value, 'services': {'database': database, 'redis': redis}}


@app.get('/health/live')
def liveness():
    return {'status': 'ok'}


@app.get('/health/ready')
def readiness():
    database = check_database()
    redis = check_redis()
    body = {'status': 'ok', 'services': {'database': database, 'redis': redis}}
    if database['status'] == 'ok' and redis['status'] == 'ok':
        return body
    body['status'] = 'error'
    return JSONResponse(status_code=503, content=body)