from fastapi import APIRouter
from pydantic import BaseModel
from typing import List

router = APIRouter()

class Message(BaseModel):
    role: str
    content: str

class ChatRequest(BaseModel):
    messages: List[Message]
    provider: str = "gemini"
    model: str = "gemini-1.5-flash"

class ChatResponse(BaseModel):
    response: str
    model: str
    status: str

@router.post("/chat", response_model=ChatResponse)
def chat_endpoint(req: ChatRequest):
    return {
        "response": "JARVIS Cloud Backend received input. Direct device-to-API inference is recommended for minimum latency.",
        "model": req.model,
        "status": "success"
    }
