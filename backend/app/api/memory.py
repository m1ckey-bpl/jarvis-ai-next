from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import List, Optional
import uuid
from datetime import datetime

router = APIRouter()

class MemoryItem(BaseModel):
    id: Optional[str] = None
    category: str
    content: str
    tags: List[str] = []
    timestamp: Optional[str] = None

# In-memory store for backend instance
_memories: List[dict] = []

@router.get("/", response_model=List[MemoryItem])
def list_memories(q: Optional[str] = None):
    if not q:
        return _memories
    query = q.lower()
    return [m for m in _memories if query in m["content"].lower() or any(query in t.lower() for t in m.get("tags", []))]

@router.post("/", response_model=MemoryItem)
def create_memory(item: MemoryItem):
    data = item.dict()
    data["id"] = data.get("id") or str(uuid.uuid4())
    data["timestamp"] = data.get("timestamp") or datetime.utcnow().isoformat()
    _memories.append(data)
    return data

@router.delete("/{memory_id}")
def delete_memory(memory_id: str):
    global _memories
    initial_len = len(_memories)
    _memories = [m for m in _memories if m["id"] != memory_id]
    if len(_memories) == initial_len:
        raise HTTPException(status_code=404, detail="Memory record not found")
    return {"status": "deleted", "id": memory_id}
