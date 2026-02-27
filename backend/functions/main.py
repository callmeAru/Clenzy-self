import os
from pathlib import Path

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse, RedirectResponse
from fastapi.staticfiles import StaticFiles

from app.routes import user, worker, admin, booking, ws, wallet, safetap
from app.database import engine, SQLALCHEMY_DATABASE_URL
from app.models import Base

# Create database tables automatically only for local SQLite development.
# In production (e.g., Supabase Postgres), schema should be managed via migrations.
if SQLALCHEMY_DATABASE_URL.startswith("sqlite"):
    Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="Clenzy API",
    description="Backend API for Clenzy User & Worker Apps",
    version="1.0.0",
)

# CORS Configuration (Flutter needs this)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Change to production domain later
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    print(f"ERROR: {str(exc)}")
    return JSONResponse(
        status_code=500,
        content={"detail": "Internal Server Error", "message": str(exc)},
        headers={
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Methods": "*",
            "Access-Control-Allow-Headers": "*",
        },
    )


# Include Routers
app.include_router(user.router, prefix="/api/users", tags=["Users"])
app.include_router(booking.router, prefix="/api/bookings", tags=["Bookings"])
app.include_router(wallet.router, prefix="/api/wallet", tags=["Wallet"])
app.include_router(ws.router, prefix="/api", tags=["WebSockets"])
app.include_router(admin.router, prefix="/api/admin", tags=["Admin"])
app.include_router(safetap.router, prefix="/api/safetap", tags=["SafeTap"])


# Serve Flutter web build (if present) under /app, and redirect "/" to it.
# Check both: (1) backend/functions/web - bundled with deployment, (2) frontend/build/web - local dev.
_BACKEND_DIR = Path(__file__).resolve().parent
_WEB_IN_FUNCTIONS = _BACKEND_DIR / "web"
_FRONTEND_BUILD_DIR = _BACKEND_DIR.parent.parent / "frontend" / "build" / "web"

_STATIC_DIR = _WEB_IN_FUNCTIONS if _WEB_IN_FUNCTIONS.is_dir() else (_FRONTEND_BUILD_DIR if _FRONTEND_BUILD_DIR.is_dir() else None)

if _STATIC_DIR:
    app.mount(
        "/app",
        StaticFiles(directory=str(_STATIC_DIR), html=True),
        name="frontend",
    )


@app.get("/")
def root():
    """
    Redirect root to Flutter web app (/app) when static files are present,
    or to FLUTTER_APP_URL if set, otherwise return JSON health message.
    """
    if _STATIC_DIR:
        return RedirectResponse(url="/app")
    flutter_url = os.getenv("FLUTTER_APP_URL", "").strip()
    if flutter_url:
        return RedirectResponse(url=flutter_url)
    return {"message": "Clenzy Backend Running Successfully"}
