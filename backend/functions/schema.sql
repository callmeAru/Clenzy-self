-- PostgreSQL Database Schema for Clenzy

-- Enable UUID extension if needed in future, but based on models we use SERIAL
-- CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Users Table
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(255),
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(255) UNIQUE,
    hashed_password VARCHAR(255) NOT NULL,
    role VARCHAR(50) DEFAULT 'user', -- 'user', 'individual_partner', 'agency_partner'
    is_active BOOLEAN DEFAULT true,
    is_verified BOOLEAN DEFAULT false,
    is_online BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Trigger Function for updated_at
CREATE OR REPLACE FUNCTION update_modified_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_users_modtime
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_modified_column();

-- 2. Partner Profiles
-- Stores extra profile data needed by the frontend PartnerProfileData model
CREATE TABLE IF NOT EXISTS partner_profiles (
    id SERIAL PRIMARY KEY,
    user_id INTEGER UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    bio TEXT,
    business_type VARCHAR(100) DEFAULT 'Individual',
    business_name VARCHAR(255),
    use_same_as_profile_name BOOLEAN DEFAULT true,
    city VARCHAR(255) DEFAULT 'New York',
    service_radius DOUBLE PRECISION DEFAULT 15.0,
    payment_method VARCHAR(100),
    payment_id VARCHAR(255),
    national_id_uploaded BOOLEAN DEFAULT false,
    certificate_uploaded BOOLEAN DEFAULT false,
    national_id_file_name VARCHAR(255),
    certificate_file_name VARCHAR(255),
    is_profile_complete BOOLEAN DEFAULT false,
    approval_status VARCHAR(50) DEFAULT 'pending', -- 'pending', 'approved', 'rejected'
    
    -- JSONB array representation for dynamic lists
    team_members JSONB DEFAULT '[]'::jsonb, 
    selected_services JSONB DEFAULT '[]'::jsonb,
    custom_skills JSONB DEFAULT '[]'::jsonb,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TRIGGER update_partner_profiles_modtime
    BEFORE UPDATE ON partner_profiles
    FOR EACH ROW
    EXECUTE FUNCTION update_modified_column();

-- 3. Jobs/Bookings
CREATE TABLE IF NOT EXISTS jobs (
    id SERIAL PRIMARY KEY,
    customer_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    worker_id INTEGER REFERENCES users(id) ON DELETE SET NULL,
    agency_id INTEGER REFERENCES users(id) ON DELETE SET NULL,
    status VARCHAR(50) DEFAULT 'searching', -- searching, accepted, arrived, started, completed, cancelled
    service_type VARCHAR(100),
    otp VARCHAR(10),
    price DOUBLE PRECISION,
    workers_needed INTEGER DEFAULT 1,
    
    -- Location details
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    address VARCHAR(255),
    description TEXT,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    accepted_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_jobs_service_type ON jobs(service_type);
CREATE INDEX idx_jobs_status ON jobs(status);

-- 4. Wallets
CREATE TABLE IF NOT EXISTS wallets (
    id SERIAL PRIMARY KEY,
    user_id INTEGER UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    balance DOUBLE PRECISION DEFAULT 0.0,
    total_earnings DOUBLE PRECISION DEFAULT 0.0,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TRIGGER update_wallets_modtime
    BEFORE UPDATE ON wallets
    FOR EACH ROW
    EXECUTE FUNCTION update_modified_column();

-- 5. Transactions
CREATE TABLE IF NOT EXISTS transactions (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE, -- Nullable if platform wide transaction
    type VARCHAR(50), -- earning, commission, withdrawal
    amount DOUBLE PRECISION,
    job_id INTEGER REFERENCES jobs(id) ON DELETE SET NULL,
    description VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 6. Notifications
CREATE TABLE IF NOT EXISTS notifications (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    type VARCHAR(50), -- new_job, job_accepted, job_status_update, payment_received
    job_id INTEGER REFERENCES jobs(id) ON DELETE CASCADE,
    title VARCHAR(255),
    body TEXT,
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
