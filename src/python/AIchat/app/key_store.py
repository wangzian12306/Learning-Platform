import json
from pathlib import Path


def load_api_keys(config_path: str) -> dict:
    path = Path(config_path)
    if not path.exists():
        raise RuntimeError(
            f"API Key 配置文件不存在: {config_path}。请基于 apikeys.example.json 创建本地配置文件。"
        )

    with path.open("r", encoding="utf-8") as file:
        data = json.load(file)

    if not isinstance(data, dict):
        raise RuntimeError("API Key 配置文件格式错误，根节点必须是对象。")

    return data


def get_provider_key(keys: dict, provider: str) -> str:
    value = keys.get(provider)
    if not value or not isinstance(value, str):
        raise RuntimeError(f"未配置 {provider} 的 API Key。")
    return value
