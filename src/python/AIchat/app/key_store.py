import json
import logging
from pathlib import Path

logger = logging.getLogger(__name__)


def load_api_keys(config_path: str) -> dict:
    path = Path(config_path)
    if not path.exists():
        logger.warning(f"API Key 配置文件不存在: {config_path}，AI 对话功能将不可用")
        return {}

    with path.open("r", encoding="utf-8") as file:
        data = json.load(file)

    if not isinstance(data, dict):
        logger.warning("API Key 配置文件格式错误，根节点必须是对象")
        return {}

    return data


def get_provider_key(keys: dict, provider: str) -> str:
    value = keys.get(provider)
    if not value or not isinstance(value, str):
        raise RuntimeError(f"未配置 {provider} 的 API Key，AI 对话功能不可用。请参考启动指南配置 API Key。")
    return value
