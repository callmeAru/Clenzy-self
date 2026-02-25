import sys
import os

# Add the parent directory to the path so we can import 'app'
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from sqlalchemy.orm import Session
from app.database import SessionLocal, engine
from app import models, auth

def create_admin(email: str, password: str, full_name: str = "Admin"):
    # Create tables if they don't exist
    models.Base.metadata.create_all(bind=engine)
    
    db: Session = SessionLocal()
    try:
        # Check if user exists
        existing_user = db.query(models.User).filter(models.User.email == email).first()
        if existing_user:
            print(f"User with email {email} already exists.")
            # Upgrade role if needed
            if existing_user.role != "admin":
                existing_user.role = "admin"
                db.commit()
                print(f"Upgraded {email} to admin role.")
            return

        # Create new admin user
        hashed_pw = auth.get_password_hash(password)
        new_admin = models.User(
            email=email,
            full_name=full_name,
            hashed_password=hashed_pw,
            role="admin",
            is_active=True,
            is_verified=True
        )
        db.add(new_admin)
        db.flush()
        
        # Create empty wallet
        new_wallet = models.Wallet(user_id=new_admin.id)
        db.add(new_wallet)
        
        db.commit()
        print(f"Successfully created admin user: {email}")

    except Exception as e:
        print(f"Error creating admin: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python scripts/create_admin.py <email> <password> [full_name]")
        sys.exit(1)
        
    email_arg = sys.argv[1]
    password_arg = sys.argv[2]
    name_arg = sys.argv[3] if len(sys.argv) > 3 else "System Admin"
    
    create_admin(email_arg, password_arg, name_arg)
