from __future__ import annotations

from fastapi import HTTPException, status
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse


def api_error(status_code: int, code: str, message: str, details: dict | None = None) -> HTTPException:
    return HTTPException(status_code=status_code, detail={'code': code, 'message': message, 'details': details or {}})


def http_exception_response(_: object, exc: HTTPException) -> JSONResponse:
    detail = exc.detail if isinstance(exc.detail, dict) else {'code': 'http_error', 'message': str(exc.detail), 'details': {}}
    return JSONResponse(status_code=exc.status_code, content=detail)


def validation_exception_response(_: object, exc: RequestValidationError) -> JSONResponse:
    return JSONResponse(
        status_code=status.HTTP_400_BAD_REQUEST,
        content={'code': 'validation_error', 'message': 'Request validation failed', 'details': {'errors': exc.errors()}},
    )