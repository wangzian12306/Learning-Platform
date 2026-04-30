from datetime import datetime

from app.config import get_settings
from app.db import get_db
from app.models import AIAbility, ChatRole
from app.repositories.chat_repository import ChatRepository
from app.schemas import ChatMessage, ChatRequest, ChatResponse, SessionHistoryResponse
from app.services.ai_provider import AIProvider


class ChatService:
    def __init__(self):
        self.settings = get_settings()
        self.repository = ChatRepository()
        self.provider = AIProvider()

    def chat(self, request: ChatRequest) -> ChatResponse:
        with get_db() as connection:
            history_rows = self.repository.get_session_messages(
                connection=connection,
                user_id=request.user_id,
                session_id=request.session_id,
                limit=request.history_limit,
            )
            input_messages = self._build_input_messages(request=request, history_rows=history_rows)
            answer = self.provider.generate(ability=request.ability, messages=input_messages, model=request.model)
            self.repository.save_message(connection, request.user_id, request.session_id, ChatRole.USER, request.question)
            self.repository.save_message(
                connection=connection,
                user_id=request.user_id,
                session_id=request.session_id,
                role=ChatRole.ASSISTANT,
                content=answer,
            )

        return ChatResponse(
            user_id=request.user_id,
            session_id=request.session_id,
            ability=request.ability,
            answer=answer,
            create_time=datetime.now(),
        )

    def get_session_history(self, user_id: int, session_id: str, limit: int) -> SessionHistoryResponse:
        with get_db() as connection:
            rows = self.repository.get_session_messages(connection, user_id, session_id, limit)

        messages = [self._row_to_model(row) for row in rows]
        return SessionHistoryResponse(user_id=user_id, session_id=session_id, messages=messages)

    def chat_stream(self, request: ChatRequest):
        with get_db() as connection:
            history_rows = self.repository.get_session_messages(
                connection=connection,
                user_id=request.user_id,
                session_id=request.session_id,
                limit=request.history_limit,
            )

        input_messages = self._build_input_messages(request=request, history_rows=history_rows)
        answer_parts = []
        for chunk in self.provider.generate_stream(messages=input_messages, model=request.model):
            answer_parts.append(chunk)
            yield chunk

        answer = "".join(answer_parts).strip()
        with get_db() as connection:
            self.repository.save_message(connection, request.user_id, request.session_id, ChatRole.USER, request.question)
            self.repository.save_message(
                connection=connection,
                user_id=request.user_id,
                session_id=request.session_id,
                role=ChatRole.ASSISTANT,
                content=answer or "（空响应）",
            )

    @staticmethod
    def _row_to_model(row: dict) -> ChatMessage:
        return ChatMessage(
            role=ChatRole(row["role"]),
            content=row["content"],
            create_time=row["create_time"],
        )

    def _build_input_messages(self, request: ChatRequest, history_rows: list[dict]) -> list[dict]:
        system_prompt = request.system_prompt or self.settings.default_system_prompt
        messages = [{"role": "system", "content": system_prompt}]

        for row in history_rows:
            role = "assistant" if row["role"] == ChatRole.ASSISTANT.value else "user"
            messages.append({"role": role, "content": row["content"]})

        user_content = request.question
        if request.ability == AIAbility.CODE_ANALYSIS:
            user_content += f"\n\n[代码分析输入]\nlanguage={request.language or 'unknown'}\n{request.code or ''}"
        elif request.ability == AIAbility.CODE_GENERATION:
            user_content += f"\n\n[代码生成约束]\nlanguage={request.language or 'unknown'}"

        messages.append({"role": "user", "content": user_content})
        return messages
