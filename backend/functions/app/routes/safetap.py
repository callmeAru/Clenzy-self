from math import radians, sin, cos, asin, sqrt
from typing import Optional

from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from sqlalchemy.orm import Session

from app import auth, models
from app.database import get_db

router = APIRouter()


class PanicRequest(BaseModel):
    job_id: int
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    notes: Optional[str] = None


class PanicResponse(BaseModel):
    alert_id: int
    job_id: int
    emergency_center_id: Optional[int]
    message: str


def _haversine_km(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    r = 6371.0
    dlat = radians(lat2 - lat1)
    dlon = radians(lon2 - lon1)
    a = sin(dlat / 2) ** 2 + cos(radians(lat1)) * cos(radians(lat2)) * sin(dlon / 2) ** 2
    c = 2 * asin(sqrt(a))
    return r * c


def _find_nearest_emergency_center(
    db: Session, latitude: float, longitude: float
) -> Optional[models.EmergencyCenter]:
    centers = (
        db.query(models.EmergencyCenter)
        .filter(models.EmergencyCenter.is_active.is_(True))
        .all()
    )
    best_center = None
    best_distance = None

    for center in centers:
        dist = _haversine_km(latitude, longitude, center.latitude, center.longitude)
        if best_distance is None or dist < best_distance:
            best_distance = dist
            best_center = center

    if best_center and best_distance is not None:
        if best_distance <= (best_center.service_radius_km or 0):
            return best_center
    return None


@router.post(
    "/panic",
    response_model=PanicResponse,
    status_code=status.HTTP_201_CREATED,
)
def trigger_panic(
    payload: PanicRequest,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(auth.get_current_user),
):
    job = db.query(models.Job).filter(models.Job.id == payload.job_id).first()
    if not job:
        raise HTTPException(status_code=404, detail="Job not found")

    if current_user.id not in (job.customer_id, job.worker_id):
        raise HTTPException(
            status_code=403, detail="You are not a participant in this job"
        )

    role_at_time = "customer" if current_user.id == job.customer_id else "worker"

    lat = payload.latitude
    lon = payload.longitude
    if lat is None or lon is None:
        lat = job.latitude
        lon = job.longitude

    alert = models.PanicAlert(
        job_id=job.id,
        triggered_by_user_id=current_user.id,
        role_at_time=role_at_time,
        latitude=lat,
        longitude=lon,
        notes=payload.notes,
    )
    db.add(alert)
    db.flush()

    emergency_center_id: Optional[int] = None
    if lat is not None and lon is not None:
        center = _find_nearest_emergency_center(db, lat, lon)
        if center:
            emergency_center_id = center.id

    db.commit()

    # TODO: Integrate with SMS/email/ops tooling here.

    return PanicResponse(
        alert_id=alert.id,
        job_id=alert.job_id,
        emergency_center_id=emergency_center_id,
        message="Emergency alert created and routed to the nearest center (if available).",
    )

