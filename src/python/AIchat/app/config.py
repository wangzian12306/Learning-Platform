from functools import lru_cache
from pathlib import Path

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    app_name: str = "AIChat Service"
    app_host: str = "0.0.0.0"
    app_port: int = 9000

    mysql_host: str = "127.0.0.1"
    mysql_port: int = 3306
    mysql_user: str = "root"
    mysql_password: str = "root"
    mysql_database: str = "learning_platform"

    default_history_limit: int = 20
    default_system_prompt: str = "你是数据结构课程助教，请给出清晰、可执行、可验证的回答。"
    qwen_model: str = "qwen3.6-plus"
    qwen_base_url: str = "https://dashscope.aliyuncs.com/compatible-mode/v1"
    api_key_file: str = str(Path(__file__).resolve().parent.parent / "config" / "apikeys.local.json")

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=False,
        extra="ignore",
    )


@lru_cache
def get_settings() -> Settings:
    return Settings()
