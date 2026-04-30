# AIChat 模块进度说明（prograss）

## 已完成的基础功能

1. 已搭建 Python 后端服务骨架（FastAPI + Uvicorn），可独立启动并监听端口。
2. 已实现 AI 模型调用适配层，当前对接阿里兼容模式接口：
   - `qwen3.6-plus` 使用 Responses API 调用；
   - `deepseek-v4-flash` 使用 Chat Completions 流式调用。
3. 已实现本地 API Key 配置读取（不依赖环境变量）：
   - 从 `config/apikeys.local.json` 读取；
   - 支持集中存放多个 provider 的 key；
   - 本地密钥文件不受 git 跟踪。
4. 已实现多轮会话上下文拼接逻辑：
   - 基于 `user_id + session_id` 从 `ai_chat` 表读取历史消息；
   - 将历史消息拼接为 `messages` 后调用模型；
   - 新会话（无历史记录）自动跳过历史拼接。
5. 已实现回答结束后的会话落库逻辑：
   - 用户提问入库（`USER`）；
   - 模型回答入库（`ASSISTANT`）。
6. 已实现流式响应能力：
   - 提供流式接口；
   - 已提供独立 Python 测试脚本用于流式输出验证。

## 当前已提供的接口

- `GET /health`  
  健康检查接口。

- `POST /api/ai/chat`  
  AI 问答接口（非流式）。

- `POST /api/ai/chat/stream`  
  AI 问答流式接口（文本流返回）。

- `POST /api/ai/code/analysis`  
  代码分析接口。

- `POST /api/ai/code/generation`  
  代码生成接口。

- `GET /api/ai/sessions/{session_id}?user_id=...&limit=...`  
  历史会话查询接口。

## 目前未完成项 / 风险说明

1. **数据库相关测试尚未实施**（按当前计划先完成功能开发）：
   - 未进行 MySQL 联通性稳定性测试；
   - 未进行真实库表数据写入/回读端到端测试；
   - 未覆盖并发场景下的会话写入与一致性验证。
2. 当前阶段以功能连通为主，后续需要补充：
   - 数据库集成测试；
   - 接口自动化测试；
   - 异常场景与错误码校验测试。
