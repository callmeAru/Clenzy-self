import os
import urllib.parse
import psycopg2
import urllib.parse
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from dotenv import load_dotenv

load_dotenv()

# Fallback to a local SQLite database if no DATABASE_URL is found
SQLALCHEMY_DATABASE_URL = os.getenv("DATABASE_URL", "sqlite:///./sql_app.db")

def create_database_if_not_exists(url):
    """
    For local Postgres (e.g., running on localhost), try to create the database
    automatically if it does not exist. For managed providers like Supabase,
    we skip this step because the database is created by the provider.
    """
    if not url.startswith("postgresql"):
        return

    parsed = urllib.parse.urlparse(url)
    hostname = (parsed.hostname or "").lower()

    # Only attempt auto-creation for local Postgres instances
    if hostname not in ("localhost", "127.0.0.1"):
        return

    db_name = parsed.path.lstrip("/")
    try:
        connection = psycopg2.connect(
            host=parsed.hostname,
            user=parsed.username or "postgres",
            password=parsed.password or "",
            port=parsed.port or 5432,
            database="postgres",
        )
        connection.autocommit = True
        with connection.cursor() as cursor:
            cursor.execute(
                "SELECT 1 FROM pg_catalog.pg_database WHERE datname = %s",
                (db_name,),
            )
            exists = cursor.fetchone()
            if not exists:
                cursor.execute(f'CREATE DATABASE "{db_name}"')
                print(f"Database {db_name} created.")
            else:
                print(f"Database {db_name} verified.")
        connection.close()
    except Exception as e:
        print(f"Failed to verify/create database: {e}")

create_database_if_not_exists(SQLALCHEMY_DATABASE_URL)

# SQLite needs connect_args={"check_same_thread": False}, Postgres doesn't
if SQLALCHEMY_DATABASE_URL.startswith("sqlite"):
    engine = create_engine(
        SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False}
    )
else:
    engine = create_engine(SQLALCHEMY_DATABASE_URL)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()