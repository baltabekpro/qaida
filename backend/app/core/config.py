from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file='.env', env_file_encoding='utf-8', extra='ignore')

    app_name: str = 'Qaida API'
    app_env: str = 'development'
    app_host: str = '0.0.0.0'
    app_port: int = 8000
    database_url: str = 'postgresql+psycopg://qaida:qaida@db:5432/qaida'
    redis_url: str = 'redis://redis:6379/0'
    default_user_email: str = 'demo@qaida.app'
    jwt_secret: str = 'change-me'
    jwt_algorithm: str = 'HS256'
    access_token_expire_minutes: int = 60
    refresh_token_expire_days: int = 14


@lru_cache
def get_settings() -> Settings:
    return Settings()
