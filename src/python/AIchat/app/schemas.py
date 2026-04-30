from datetime import datetime
from typing import Optional

from pydantic import BaseModel, Field

from app.models import AIAbility, ChatRole


class ChatRequest(BaseModel):
    user_id: int = Field(..., ge=1)
    session_id: str = Field(..., min_length=1, max_length=100)
    question: str = Field(..., min_length=1)
    model: str = Field(default="qwen3.6-plus", min_length=1, max_length=100)
    ability: AIAbility = AIAbility.QA
    code: Optional[str] = None
    language: Optional[str] = None
    history_limit: int = Field(default=20, ge=1, le=100)
    system_prompt: Optional[str] = None


class ChatMessage(BaseModel):
    role: ChatRole
    content: str
    create_time: datetime


class ChatResponse(BaseModel):
    user_id: int
    session_id: str
    ability: AIAbility
    answer: str
    create_time: datetime


class SessionHistoryResponse(BaseModel):
    user_id: int
    session_id: str
    messages: list[ChatMessage]
