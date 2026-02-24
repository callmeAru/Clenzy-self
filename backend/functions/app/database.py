import pymysql
import os
import urllib.parse
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from dotenv import load_dotenv

load_dotenv()

# Fallback to a local SQLite database if no PostgreSQL URL is found
SQLALCHEMY_DATABASE_URL = os.getenv("DATABASE_URL", "sqlite:///./sql_app.db")

def create_database_if_not_exists(url):
    if url.startswith("mysql"):
        parsed = urllib.parse.urlparse(url)
        db_name = parsed.path.lstrip('/')
        try:
            connection = pymysql.connect(
                host=parsed.hostname,
                user=parsed.username or "root",
                password=parsed.password or "",
                port=parsed.port or 3306,
            )
            with connection.cursor() as cursor:
                cursor.execute(f"CREATE DATABASE IF NOT EXISTS `{db_name}`")
            connection.commit()
            connection.close()
            print(f"Database {db_name} verified/created.")
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