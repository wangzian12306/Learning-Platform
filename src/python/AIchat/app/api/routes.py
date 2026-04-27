from fastapi import APIRouter, Query
from fastapi.responses import StreamingResponse

from app.models import AIAbility
from app.schemas import ChatRequest, ChatResponse, SessionHistoryResponse
from app.services.chat_service import ChatService

router = APIRouter(prefix="/api/ai", tags=["AI Chat"])
chat_service = ChatService()


@router.post("/chat", response_model=ChatResponse)
def ai_chat(request: ChatRequest):
    return chat_service.chat(request.model_copy(update={"ability": AIAbility.QA}))


@router.post("/chat/stream")
def ai_chat_stream(request: ChatRequest):
    stream_request = request.model_copy(update={"ability": AIAbility.QA})
    return StreamingResponse(chat_service.chat_stream(stream_request), media_type="text/plain; charset=utf-8")


@router.post("/code/analysis", response_model=ChatResponse)
def analyze_code(request: ChatRequest):
    return chat_service.chat(request.model_copy(update={"ability": AIAbility.CODE_ANALYSIS}))


@router.post("/code/generation", response_model=ChatResponse)
def generate_code(request: ChatRequest):
    return chat_service.chat(request.model_copy(update={"ability": AIAbility.CODE_GENERATION}))


@router.get("/sessions/{session_id}", response_model=SessionHistoryResponse)
def query_session_history(
    session_id: str,
    user_id: int = Query(..., ge=1),
    limit: int = Query(50, ge=1, le=200),
):
    return chat_service.get_session_history(user_id=user_id, session_id=session_id, limit=limit)
