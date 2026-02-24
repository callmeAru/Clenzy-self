from sqlalchemy import Column, Integer, String, Boolean, DateTime, Float, ForeignKey, Text
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from .database import Base

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    full_name = Column(String(255), index=True)
    email = Column(String(255), unique=True, index=True)
    phone = Column(String(255), unique=True, index=True)
    hashed_password = Column(String(255), nullable=False)
    role = Column(String(50), default="user") # 'user', 'individual_partner', 'agency_partner'
    is_active = Column(Boolean, default=True)
    is_verified = Column(Boolean, default=False)
    is_online = Column(Boolean, default=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    jobs_as_customer = relationship("Job", foreign_keys="Job.customer_id", back_populates="customer")
    jobs_as_worker = relationship("Job", foreign_keys="Job.worker_id", back_populates="worker")
    wallet = relationship("Wallet", back_populates="user", uselist=False)

class Job(Base):
    __tablename__ = "jobs"

    id = Column(Integer, primary_key=True, index=True)
    customer_id = Column(Integer, ForeignKey("users.id"))
    worker_id = Column(Integer, ForeignKey("users.id"), nullable=True)
    agency_id = Column(Integer, ForeignKey("users.id"), nullable=True)
    status = Column(String(50), default="searching") # searching, accepted, arrived, started, completed, cancelled
    service_type = Column(String(100), index=True)
    otp = Column(String(10))
    price = Column(Float)
    workers_needed = Column(Integer, default=1)
    
    # Location
    latitude = Column(Float)
    longitude = Column(Float)
    address = Column(String(255))
    description = Column(Text, nullable=True)

    created_at = Column(DateTime(timezone=True), server_default=func.now())
    accepted_at = Column(DateTime(timezone=True), nullable=True)
    completed_at = Column(DateTime(timezone=True), nullable=True)

    customer = relationship("User", foreign_keys=[customer_id], back_populates="jobs_as_customer")
    worker = relationship("User", foreign_keys=[worker_id], back_populates="jobs_as_worker")

class Notification(Base):
    __tablename__ = "notifications"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    type = Column(String(50)) # new_job, job_accepted, job_status_update, payment_received
    job_id = Column(Integer, ForeignKey("jobs.id"), nullable=True)
    title = Column(String(255))
    body = Column(Text)
    is_read = Column(Boolean, default=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

class Wallet(Base):
    __tablename__ = "wallets"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), unique=True)
    balance = Column(Float, default=0.0)
    total_earnings = Column(Float, default=0.0)
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    user = relationship("User", back_populates="wallet")

class Transaction(Base):
    __tablename__ = "transactions"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=True)  # Platform transactions have null user_id
    type = Column(String(50)) # earning, commission
    amount = Column(Float)
    job_id = Column(Integer, ForeignKey("jobs.id"), nullable=True)
    description = Column(String(255))
    created_at = Column(DateTime(timezone=True), server_default=func.now())
