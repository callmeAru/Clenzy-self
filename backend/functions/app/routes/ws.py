import json
from typing import Dict, List, Optional

from fastapi import APIRouter, WebSocket, WebSocketDisconnect

from app.database import SessionLocal
from app import models

router = APIRouter()

class ConnectionManager:
    def __init__(self):
        # Maps user_id to a list of active websocket connections
        self.active_connections: Dict[int, List[WebSocket]] = {}

    async def connect(self, websocket: WebSocket, user_id: int):
        await websocket.accept()
        if user_id not in self.active_connections:
            self.active_connections[user_id] = []
        self.active_connections[user_id].append(websocket)

    def disconnect(self, websocket: WebSocket, user_id: int):
        if user_id in self.active_connections:
            self.active_connections[user_id].remove(websocket)
            if not self.active_connections[user_id]:
                del self.active_connections[user_id]

    async def send_personal_message(self, message: dict, user_id: int):
        if user_id in self.active_connections:
            for connection in self.active_connections[user_id]:
                await connection.send_json(message)

    async def broadcast(self, message: dict):
        for connections in self.active_connections.values():
            for connection in connections:
                await connection.send_json(message)

manager = ConnectionManager()

def _get_job_participant_counterparty(job: models.Job, user_id: int) -> Optional[int]:
    """
    Given a job and a user_id (customer or worker), return the other party's user_id,
    or None if the user is not part of this job or the counterparty is missing.
    """
    if job.customer_id == user_id:
        return job.worker_id
    if job.worker_id == user_id:
        return job.customer_id
    return None


@router.websocket("/ws/{user_id}")
async def websocket_endpoint(websocket: WebSocket, user_id: int):
    await manager.connect(websocket, user_id)
    try:
        while True:
            raw = await websocket.receive_text()

            # Handle both plain pings and structured JSON messages
            try:
                message = json.loads(raw)
            except json.JSONDecodeError:
                # Non-JSON payloads are ignored for now
                continue

            msg_type = message.get("type")

            if msg_type == "location_update":
                job_id = message.get("jobId")
                data = message.get("data") or {}
                if not job_id:
                    continue

                db = SessionLocal()
                try:
                    job = db.query(models.Job).filter(models.Job.id == job_id).first()
                    if not job:
                        continue

                    counterparty_id = _get_job_participant_counterparty(job, user_id)
                    if counterparty_id:
                        await manager.send_personal_message(
                            {
                                "type": "location_update",
                                "jobId": job_id,
                                "data": data,
                            },
                            counterparty_id,
                        )
                finally:
                    db.close()
    except WebSocketDisconnect:
        manager.disconnect(websocket, user_id)
