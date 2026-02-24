from fastapi import APIRouter

router = APIRouter()

@router.get("/")
def get_workers():
    return {"message": "List of workers"}