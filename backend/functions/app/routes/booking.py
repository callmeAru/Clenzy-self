from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from .. import models, schemas, auth
from ..database import get_db
import random
from datetime import datetime

router = APIRouter()

def generate_otp():
    return str(random.randint(1000, 9999))

@router.post("/", response_model=schemas.JobResponse)
def create_job(job: schemas.JobCreate, db: Session = Depends(get_db), current_user: models.User = Depends(auth.get_current_user)):
    otp = generate_otp()
    new_job = models.Job(
        customer_id=current_user.id,
        status="searching",
        service_type=job.service_type,
        otp=otp,
        price=job.price,
        workers_needed=job.workers_needed,
        latitude=job.latitude,
        longitude=job.longitude,
        address=job.address,
        description=job.description
    )
    db.add(new_job)
    db.commit()
    db.refresh(new_job)
    return new_job

@router.get("/customer", response_model=list[schemas.JobResponse])
def get_customer_jobs(db: Session = Depends(get_db), current_user: models.User = Depends(auth.get_current_user)):
    return db.query(models.Job).filter(models.Job.customer_id == current_user.id).all()

@router.get("/worker", response_model=list[schemas.JobResponse])
def get_worker_jobs(db: Session = Depends(get_db), current_user: models.User = Depends(auth.get_current_user)):
    return db.query(models.Job).filter(models.Job.worker_id == current_user.id).all()

@router.get("/available", response_model=list[schemas.JobResponse])
def get_available_jobs(db: Session = Depends(get_db), current_user: models.User = Depends(auth.get_current_user)):
    if current_user.role == "user":
        raise HTTPException(status_code=403, detail="Not authorized")
    return db.query(models.Job).filter(models.Job.status == "searching").all()

@router.post("/{job_id}/accept", response_model=schemas.JobResponse)
def accept_job(job_id: int, db: Session = Depends(get_db), current_user: models.User = Depends(auth.get_current_user)):
    job = db.query(models.Job).filter(models.Job.id == job_id).first()
    if not job:
        raise HTTPException(status_code=404, detail="Job not found")
    if job.status != "searching":
        raise HTTPException(status_code=400, detail="Job is no longer available")
    if current_user.role == "user":
        raise HTTPException(status_code=403, detail="Only workers can accept jobs")
        
    job.worker_id = current_user.id
    job.status = "accepted"
    job.accepted_at = datetime.utcnow()
    db.commit()
    db.refresh(job)
    return job

@router.put("/{job_id}/status", response_model=schemas.JobResponse)
def update_job_status(job_id: int, new_status: str, db: Session = Depends(get_db), current_user: models.User = Depends(auth.get_current_user)):
    job = db.query(models.Job).filter(models.Job.id == job_id).first()
    if not job:
        raise HTTPException(status_code=404, detail="Job not found")
        
    valid_transitions = {
        'accepted': ['arrived'],
        'arrived': ['started'],
        'started': ['completed'],
    }
    
    if job.worker_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not assigned to this job")
        
    if new_status not in valid_transitions.get(job.status, []):
        raise HTTPException(status_code=400, detail=f"Cannot transition from {job.status} to {new_status}")
    
    job.status = new_status
    db.commit()
    db.refresh(job)
    return job

@router.post("/{job_id}/verify-otp", response_model=schemas.JobResponse)
def verify_otp(job_id: int, otp: str, db: Session = Depends(get_db), current_user: models.User = Depends(auth.get_current_user)):
    job = db.query(models.Job).filter(models.Job.id == job_id).first()
    if not job:
        raise HTTPException(status_code=404, detail="Job not found")
        
    if job.otp != otp:
        raise HTTPException(status_code=400, detail="Invalid OTP")
        
    job.status = "completed"
    job.completed_at = datetime.utcnow()
    
    # Platform / worker commission logic here
    worker_share = float(job.price) * 0.85
    platform_commission = float(job.price) * 0.15
    
    worker_wallet = db.query(models.Wallet).filter(models.Wallet.user_id == job.worker_id).first()
    if worker_wallet:
        worker_wallet.balance += worker_share
        worker_wallet.total_earnings += worker_share
        
    # Transactions
    db.add(models.Transaction(user_id=job.worker_id, type="earning", amount=worker_share, job_id=job.id, description="Job earnings"))
    db.add(models.Transaction(user_id=None, type="commission", amount=platform_commission, job_id=job.id, description="Platform commission"))
    
    db.commit()
    db.refresh(job)
    return job
