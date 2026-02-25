from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import func
from typing import List

from .. import models, schemas, auth
from ..database import get_db

router = APIRouter()

@router.get("/stats", response_model=schemas.AdminStatsResponse)
def get_admin_dashboard_stats(
    db: Session = Depends(get_db), 
    current_admin: models.User = Depends(auth.get_current_admin)
):
    total_users = db.query(models.User).filter(models.User.role == "user").count()
    total_partners = db.query(models.User).filter(
        models.User.role.in_(["individual_partner", "agency_partner"])
    ).count()
    total_jobs = db.query(models.Job).count()
    
    # Calculate revenue (just the completed jobs total price for now, or sum of commissions if transactions exist)
    total_revenue_query = db.query(func.sum(models.Job.price)).filter(models.Job.status == "completed").scalar()
    total_revenue = total_revenue_query if total_revenue_query else 0.0
    
    pending_partners = db.query(models.PartnerProfile).filter(
        models.PartnerProfile.approval_status == "pending"
    ).count()
    
    return schemas.AdminStatsResponse(
        total_users=total_users,
        total_partners=total_partners,
        total_jobs=total_jobs,
        total_revenue=total_revenue,
        pending_partners=pending_partners
    )

@router.get("/users", response_model=List[schemas.UserResponse])
def get_all_users(
    skip: int = 0, limit: int = 100, 
    db: Session = Depends(get_db), 
    current_admin: models.User = Depends(auth.get_current_admin)
):
    users = db.query(models.User).offset(skip).limit(limit).all()
    return users

@router.put("/users/{user_id}/status")
def toggle_user_status(
    user_id: int,
    is_active: bool,
    db: Session = Depends(get_db),
    current_admin: models.User = Depends(auth.get_current_admin)
):
    user = db.query(models.User).filter(models.User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    # Prevent self-deactivation
    if user.id == current_admin.id and not is_active:
        raise HTTPException(status_code=400, detail="Cannot deactivate yourself")

    user.is_active = is_active
    db.commit()
    return {"message": f"User status updated. Active: {is_active}"}

@router.get("/jobs", response_model=List[schemas.JobResponse])
def get_all_jobs(
    skip: int = 0, limit: int = 100,
    db: Session = Depends(get_db),
    current_admin: models.User = Depends(auth.get_current_admin)
):
    jobs = db.query(models.Job).order_by(models.Job.created_at.desc()).offset(skip).limit(limit).all()
    return jobs

@router.put("/partner-approvals/{profile_id}")
def approve_or_reject_partner(
    profile_id: int,
    approve: bool,
    db: Session = Depends(get_db),
    current_admin: models.User = Depends(auth.get_current_admin)
):
    profile = db.query(models.PartnerProfile).filter(models.PartnerProfile.id == profile_id).first()
    if not profile:
        raise HTTPException(status_code=404, detail="Partner profile not found")
        
    if approve:
        profile.approval_status = "approved"
    else:
        profile.approval_status = "rejected"
        
    db.commit()
    return {"message": f"Partner profile has been {profile.approval_status}"}

@router.get("/partner-approvals", response_model=List[schemas.AdminPartnerProfileResponse])
def get_pending_partners(
    skip: int = 0, limit: int = 100,
    db: Session = Depends(get_db),
    current_admin: models.User = Depends(auth.get_current_admin)
):
    profiles = db.query(models.PartnerProfile).filter(
        models.PartnerProfile.approval_status == "pending"
    ).offset(skip).limit(limit).all()
    return profiles