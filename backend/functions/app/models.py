from sqlalchemy import Column, Integer, String, Boolean, DateTime, Float, ForeignKey, Text, JSON
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
    partner_profile = relationship("PartnerProfile", back_populates="user", uselist=False)

class PartnerProfile(Base):
    __tablename__ = "partner_profiles"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), unique=True)
    bio = Column(Text, nullable=True)
    business_type = Column(String(100), default="Individual")
    business_name = Column(String(255), nullable=True)
    use_same_as_profile_name = Column(Boolean, default=True)
    city = Column(String(255), default="New York")
    service_radius = Column(Float, default=15.0)
    payment_method = Column(String(100), nullable=True)
    payment_id = Column(String(255), nullable=True)
    national_id_uploaded = Column(Boolean, default=False)
    certificate_uploaded = Column(Boolean, default=False)
    national_id_file_name = Column(String(255), nullable=True)
    certificate_file_name = Column(String(255), nullable=True)
    is_profile_complete = Column(Boolean, default=False)
    approval_status = Column(String(50), default="pending")
    
    team_members = Column(JSON, default=list)
    selected_services = Column(JSON, default=list)
    custom_skills = Column(JSON, default=list)
    
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    user = relationship("User", back_populates="partner_profile")

class Job(Base):
    __tablename__ = "jobs"

    id = Column(Integer, primary_key=True, index=True)
    customer_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"))
    worker_id = Column(Integer, ForeignKey("users.id", ondelete="SET NULL"), nullable=True)
    agency_id = Column(Integer, ForeignKey("users.id", ondelete="SET NULL"), nullable=True)
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
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"))
    type = Column(String(50)) # new_job, job_accepted, job_status_update, payment_received
    job_id = Column(Integer, ForeignKey("jobs.id", ondelete="CASCADE"), nullable=True)
    title = Column(String(255))
    body = Column(Text)
    is_read = Column(Boolean, default=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

class Wallet(Base):
    __tablename__ = "wallets"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), unique=True)
    balance = Column(Float, default=0.0)
    total_earnings = Column(Float, default=0.0)
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    user = relationship("User", back_populates="wallet")

class Transaction(Base):
    __tablename__ = "transactions"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=True)  # Platform transactions can be platform-wide when user_id is null
    type = Column(String(50)) # earning, commission
    amount = Column(Float)
    job_id = Column(Integer, ForeignKey("jobs.id"), nullable=True)
    description = Column(String(255))
    created_at = Column(DateTime(timezone=True), server_default=func.now())


class EmergencyCenter(Base):
    __tablename__ = "emergency_centers"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(255), nullable=False)
    latitude = Column(Float, nullable=False)
    longitude = Column(Float, nullable=False)
    contact_phone = Column(String(50), nullable=True)
    contact_email = Column(String(255), nullable=True)
    is_active = Column(Boolean, default=True)
    service_radius_km = Column(Float, default=10.0)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())


class PanicAlert(Base):
    __tablename__ = "panic_alerts"

    id = Column(Integer, primary_key=True, index=True)
    job_id = Column(Integer, ForeignKey("jobs.id", ondelete="CASCADE"), nullable=False)
    triggered_by_user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    role_at_time = Column(String(50))  # 'customer' or 'worker'
    latitude = Column(Float, nullable=True)
    longitude = Column(Float, nullable=True)
    status = Column(String(50), default="open")  # open, in_progress, resolved
    notes = Column(Text, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    resolved_at = Column(DateTime(timezone=True), nullable=True)
