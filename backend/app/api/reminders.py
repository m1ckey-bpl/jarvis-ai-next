from fastapi import APIRouter
from pydantic import BaseModel
from typing import List, Optional
import uuid

router = APIRouter()

class Reminder(BaseModel):
    id: Optional[str] = None
    title: str
    scheduled_date: str
    is_completed: bool = False

_reminders: List[dict] = []

@router.get("/", response_model=List[Reminder])
def get_reminders():
    return _reminders

@router.post("/", response_model=Reminder)
def create_reminder(r: Reminder):
    data = r.dict()
    data["id"] = data.get("id") or str(uuid.uuid4())
    _reminders.append(data)
    return data
