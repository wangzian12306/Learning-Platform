# AI Chat Python Backend

该目录提供独立的 AI 后端服务（仅后端，不含前端）。

## 功能范围

- AI 对话接口：`POST /api/ai/chat`
- 代码分析接口：`POST /api/ai/code/analysis`
- 代码生成接口：`POST /api/ai/code/generation`
- 会话历史查询：`GET /api/ai/sessions/{session_id}?user_id=1`

## 当前实现说明

- 已实现可长期运行的 HTTP 服务（FastAPI + Uvicorn）
- 已实现对 `ai_chat` 表的落库与多轮上下文查询
- 已接入通义千问（Responses API 兼容模式）

## API Key 配置

1. 复制 `config/apikeys.example.json` 为 `config/apikeys.local.json`
2. 在 `apikeys.local.json` 中填写 `qwen` 的 Key
3. `apikeys.local.json` 已加入仓库根 `.gitignore`，不会被 git 跟踪

示例：

```json
{
  "qwen": "sk-xxx",
  "deepseek": "",
  "openai": ""
}
```

## 安装与运行

```bash
cd src/python/AIchat
python -m venv .venv
# Windows
.venv\Scripts\activate
pip install -r requirements.txt
python run.py
```

默认监听 `0.0.0.0:9000`，健康检查接口为 `GET /health`。

## 环境变量（可选）

- `APP_HOST`（默认 `0.0.0.0`）
- `APP_PORT`（默认 `9000`）
- `MYSQL_HOST`（默认 `127.0.0.1`）
- `MYSQL_PORT`（默认 `3306`）
- `MYSQL_USER`（默认 `root`）
- `MYSQL_PASSWORD`（默认 `root`）
- `MYSQL_DATABASE`（默认 `learning_platform`）
- `DEFAULT_HISTORY_LIMIT`（默认 `20`）
- `DEFAULT_SYSTEM_PROMPT`（默认数据结构助教提示词）
- `QWEN_MODEL`（默认 `qwen-plus`）
- `QWEN_BASE_URL`（默认中国内地节点）
- `API_KEY_FILE`（默认 `./config/apikeys.local.json`）
