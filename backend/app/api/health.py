from fastapi import APIRouter
from datetime import datetime

router = APIRouter()

@router.get("/")
def get_health():
    return {
        "status": "healthy",
        "timestamp": datetime.utcnow().isoformat(),
        "subsystems": {
            "memory": "operational",
            "agent": "operational",
            "scheduler": "operational"
        }
    }
