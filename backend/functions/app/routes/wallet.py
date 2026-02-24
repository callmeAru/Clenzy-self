from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from .. import models, schemas, auth
from ..database import get_db

router = APIRouter()

@router.get("/balance")
def get_balance(db: Session = Depends(get_db), current_user: models.User = Depends(auth.get_current_user)):
    wallet = db.query(models.Wallet).filter(models.Wallet.user_id == current_user.id).first()
    if not wallet:
        return {"balance": 0.0, "total_earnings": 0.0}
    return {"balance": wallet.balance, "total_earnings": wallet.total_earnings}

@router.get("/transactions")
def get_transactions(db: Session = Depends(get_db), current_user: models.User = Depends(auth.get_current_user)):
    transactions = db.query(models.Transaction).filter(models.Transaction.user_id == current_user.id).order_by(models.Transaction.created_at.desc()).all()
    return transactions
