from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api import health, memory, agent, reminders

app = FastAPI(
    title="JARVIS Backend",
    version="1.0.0",
    description="Autonomous AI Personal Assistant Backend Service"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(health.router, prefix="/health", tags=["health"])
app.include_router(memory.router, prefix="/memory", tags=["memory"])
app.include_router(agent.router, prefix="/agent", tags=["agent"])
app.include_router(reminders.router, prefix="/reminders", tags=["reminders"])

@app.get("/")
def root():
    return {
        "status": "online",
        "service": "JARVIS AI Assistant Backend",
        "version": "1.0.0"
    }
