from fastapi import APIRouter, Depends

router = APIRouter()

@router.get("/dashboard")
def admin_dashboard():
    return {"message": "Admin dashboard data"}