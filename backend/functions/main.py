import os
from pathlib import Path

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse, RedirectResponse, FileResponse
from fastapi.staticfiles import StaticFiles

from app.routes import user, worker, admin, booking, ws, wallet, safetap
from app.database import engine, SQLALCHEMY_DATABASE_URL
from app.models import Base



if SQLALCHEMY_DATABASE_URL.startswith("sqlite"):
    Base.metadata.create_all(bind=engine)



app = FastAPI(
    title="Clenzy API",
    description="Backend API for Clenzy User & Worker Apps",
    version="1.0.0",
)



app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # tighten in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    print(f"ERROR: {str(exc)}")
    return JSONResponse(
        status_code=500,
        content={"detail": "Internal Server Error"},
        headers={
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Methods": "*",
            "Access-Control-Allow-Headers": "*",
        },
    )



app.include_router(user.router, prefix="/api/users", tags=["Users"])
app.include_router(booking.router, prefix="/api/bookings", tags=["Bookings"])
app.include_router(wallet.router, prefix="/api/wallet", tags=["Wallet"])
app.include_router(ws.router, prefix="/api", tags=["WebSockets"])
app.include_router(admin.router, prefix="/api/admin", tags=["Admin"])
app.include_router(safetap.router, prefix="/api/safetap", tags=["SafeTap"])



BASE_DIR = Path(__file__).resolve().parent

WEB_IN_BACKEND = BASE_DIR / "web"
WEB_IN_FRONTEND = BASE_DIR.parent.parent / "frontend" / "build" / "web"

STATIC_DIR = (
    WEB_IN_BACKEND if WEB_IN_BACKEND.is_dir()
    else WEB_IN_FRONTEND if WEB_IN_FRONTEND.is_dir()
    else None
)

# Serve Flutter static files under /app
if STATIC_DIR:
    app.mount(
        "/app",
        StaticFiles(directory=str(STATIC_DIR), html=True),
        name="flutter",
    )



@app.get("/")
def root():
    """
    Serve Flutter web app at root if present.
    Otherwise redirect to external Flutter URL or show health JSON.
    """
    if STATIC_DIR:
        index_file = STATIC_DIR / "index.html"
        if index_file.exists():
            return FileResponse(index_file)

    flutter_url = os.getenv("FLUTTER_APP_URL", "").strip()
    if flutter_url:
        return RedirectResponse(url=flutter_url)

    return {"message": "Clenzy Backend Running Successfully"}