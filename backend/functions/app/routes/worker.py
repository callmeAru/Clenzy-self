from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from .. import models, schemas, auth
from ..database import get_db

# Partner roles that can accept jobs (workers)
_WORKER_ROLES = ("individual_partner", "agency_partner")

router = APIRouter(
    prefix="/workers",
    tags=["Workers"],
)


def _require_worker(current_user: models.User) -> None:
    if current_user.role not in _WORKER_ROLES:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only workers/partners can access this endpoint",
        )


@router.get("/me", response_model=schemas.UserResponse)
def get_worker_profile(
    current_user: models.User = Depends(auth.get_current_user),
):
    _require_worker(current_user)
    return current_user


@router.put("/availability")
def update_worker_availability(
    is_available: bool,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(auth.get_current_user),
):
    _require_worker(current_user)
    current_user.is_online = is_available
    db.commit()
    return {"message": f"Availability set to {is_available}"}


@router.get("/jobs", response_model=list[schemas.JobResponse])
def get_worker_jobs(
    db: Session = Depends(get_db),
    current_user: models.User = Depends(auth.get_current_user),
):
    _require_worker(current_user)
    return (
        db.query(models.Job)
        .filter(models.Job.worker_id == current_user.id)
        .order_by(models.Job.created_at.desc())
        .all()
    )


@router.get("/earnings")
def get_worker_earnings(
    db: Session = Depends(get_db),
    current_user: models.User = Depends(auth.get_current_user),
):
    _require_worker(current_user)
    wallet = db.query(models.Wallet).filter(
        models.Wallet.user_id == current_user.id
    ).first()
    if not wallet:
        return {"balance": 0.0, "total_earnings": 0.0}
    return {
        "balance": wallet.balance,
        "total_earnings": wallet.total_earnings,
    }