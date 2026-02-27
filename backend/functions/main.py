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
_BACKEND_DIR = Path(__file__).resolve().parent
_FRONTEND_BUILD_DIR = _BACKEND_DIR.parent.parent / "frontend" / "build" / "web"

if _FRONTEND_BUILD_DIR.is_dir():
    app.mount(
        "/app",
        StaticFiles(directory=str(_FRONTEND_BUILD_DIR), html=True),
        name="frontend",
    )


@app.get("/")
def root():
    """
    When deployed with a Flutter web build, redirect the root URL to the
    compiled web app. If the web assets are not present, fall back to a
    simple JSON health message.
    """
    if _FRONTEND_BUILD_DIR.is_dir():
        return RedirectResponse(url="/app")
    return {"message": "Clenzy Backend Running Successfully"}
