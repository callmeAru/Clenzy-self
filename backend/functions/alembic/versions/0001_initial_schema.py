from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = "0001_initial_schema"
down_revision = None
branch_labels = None
depends_on = None


def create_updated_at_trigger():
    bind = op.get_bind()
    if bind.dialect.name != "postgresql":
        return

    op.execute(
        """
        CREATE OR REPLACE FUNCTION update_modified_column()
        RETURNS TRIGGER AS $$
        BEGIN
            NEW.updated_at = CURRENT_TIMESTAMP;
            RETURN NEW;
        END;
        $$ language 'plpgsql';
        """
    )

    # Triggers will be attached after table creation.


def upgrade() -> None:
    # Users table
    op.create_table(
        "users",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column("full_name", sa.String(length=255), index=True),
        sa.Column("email", sa.String(length=255), unique=True, nullable=False, index=True),
        sa.Column("phone", sa.String(length=255), unique=True, index=True),
        sa.Column("hashed_password", sa.String(length=255), nullable=False),
        sa.Column("role", sa.String(length=50), nullable=False, server_default="user"),
        sa.Column("is_active", sa.Boolean(), nullable=False, server_default=sa.text("true")),
        sa.Column("is_verified", sa.Boolean(), nullable=False, server_default=sa.text("false")),
        sa.Column("is_online", sa.Boolean(), nullable=False, server_default=sa.text("false")),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("CURRENT_TIMESTAMP")),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.text("CURRENT_TIMESTAMP")),
    )

    # Partner profiles
    op.create_table(
        "partner_profiles",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column("user_id", sa.Integer(), sa.ForeignKey("users.id", ondelete="CASCADE"), unique=True),
        sa.Column("bio", sa.Text(), nullable=True),
        sa.Column("business_type", sa.String(length=100), nullable=False, server_default="Individual"),
        sa.Column("business_name", sa.String(length=255), nullable=True),
        sa.Column("use_same_as_profile_name", sa.Boolean(), nullable=False, server_default=sa.text("true")),
        sa.Column("city", sa.String(length=255), nullable=False, server_default="New York"),
        sa.Column("service_radius", sa.Float(), nullable=False, server_default="15.0"),
        sa.Column("payment_method", sa.String(length=100), nullable=True),
        sa.Column("payment_id", sa.String(length=255), nullable=True),
        sa.Column("national_id_uploaded", sa.Boolean(), nullable=False, server_default=sa.text("false")),
        sa.Column("certificate_uploaded", sa.Boolean(), nullable=False, server_default=sa.text("false")),
        sa.Column("national_id_file_name", sa.String(length=255), nullable=True),
        sa.Column("certificate_file_name", sa.String(length=255), nullable=True),
        sa.Column("is_profile_complete", sa.Boolean(), nullable=False, server_default=sa.text("false")),
        sa.Column("approval_status", sa.String(length=50), nullable=False, server_default="pending"),
        sa.Column("team_members", sa.JSON(), nullable=False, server_default="[]"),
        sa.Column("selected_services", sa.JSON(), nullable=False, server_default="[]"),
        sa.Column("custom_skills", sa.JSON(), nullable=False, server_default="[]"),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("CURRENT_TIMESTAMP")),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.text("CURRENT_TIMESTAMP")),
    )

    # Jobs / bookings
    op.create_table(
        "jobs",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column("customer_id", sa.Integer(), sa.ForeignKey("users.id", ondelete="CASCADE")),
        sa.Column("worker_id", sa.Integer(), sa.ForeignKey("users.id", ondelete="SET NULL"), nullable=True),
        sa.Column("agency_id", sa.Integer(), sa.ForeignKey("users.id", ondelete="SET NULL"), nullable=True),
        sa.Column("status", sa.String(length=50), nullable=False, server_default="searching"),
        sa.Column("service_type", sa.String(length=100), index=True),
        sa.Column("otp", sa.String(length=10)),
        sa.Column("price", sa.Float()),
        sa.Column("workers_needed", sa.Integer(), nullable=False, server_default="1"),
        sa.Column("latitude", sa.Float()),
        sa.Column("longitude", sa.Float()),
        sa.Column("address", sa.String(length=255)),
        sa.Column("description", sa.Text(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("CURRENT_TIMESTAMP")),
        sa.Column("accepted_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("completed_at", sa.DateTime(timezone=True), nullable=True),
    )

    op.create_index("idx_jobs_service_type", "jobs", ["service_type"])
    op.create_index("idx_jobs_status", "jobs", ["status"])

    # Wallets
    op.create_table(
        "wallets",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column("user_id", sa.Integer(), sa.ForeignKey("users.id", ondelete="CASCADE"), unique=True),
        sa.Column("balance", sa.Float(), nullable=False, server_default="0.0"),
        sa.Column("total_earnings", sa.Float(), nullable=False, server_default="0.0"),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.text("CURRENT_TIMESTAMP")),
    )

    # Transactions
    op.create_table(
        "transactions",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column("user_id", sa.Integer(), sa.ForeignKey("users.id", ondelete="CASCADE"), nullable=True),
        sa.Column("type", sa.String(length=50)),
        sa.Column("amount", sa.Float()),
        sa.Column("job_id", sa.Integer(), sa.ForeignKey("jobs.id", ondelete="SET NULL"), nullable=True),
        sa.Column("description", sa.String(length=255)),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("CURRENT_TIMESTAMP")),
    )

    # Notifications
    op.create_table(
        "notifications",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column("user_id", sa.Integer(), sa.ForeignKey("users.id", ondelete="CASCADE")),
        sa.Column("type", sa.String(length=50)),
        sa.Column("job_id", sa.Integer(), sa.ForeignKey("jobs.id", ondelete="CASCADE"), nullable=True),
        sa.Column("title", sa.String(length=255)),
        sa.Column("body", sa.Text()),
        sa.Column("is_read", sa.Boolean(), nullable=False, server_default=sa.text("false")),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("CURRENT_TIMESTAMP")),
    )

    # Postgres-specific updated_at triggers
    create_updated_at_trigger()

    bind = op.get_bind()
    if bind.dialect.name == "postgresql":
        op.execute(
            """
            CREATE TRIGGER update_users_modtime
                BEFORE UPDATE ON users
                FOR EACH ROW
                EXECUTE FUNCTION update_modified_column();
            """
        )
        op.execute(
            """
            CREATE TRIGGER update_partner_profiles_modtime
                BEFORE UPDATE ON partner_profiles
                FOR EACH ROW
                EXECUTE FUNCTION update_modified_column();
            """
        )
        op.execute(
            """
            CREATE TRIGGER update_wallets_modtime
                BEFORE UPDATE ON wallets
                FOR EACH ROW
                EXECUTE FUNCTION update_modified_column();
            """
        )


def downgrade() -> None:
    bind = op.get_bind()
    if bind.dialect.name == "postgresql":
        op.execute("DROP TRIGGER IF EXISTS update_wallets_modtime ON wallets;")
        op.execute("DROP TRIGGER IF EXISTS update_partner_profiles_modtime ON partner_profiles;")
        op.execute("DROP TRIGGER IF EXISTS update_users_modtime ON users;")
        op.execute("DROP FUNCTION IF EXISTS update_modified_column();")

    op.drop_table("notifications")
    op.drop_table("transactions")
    op.drop_table("wallets")
    op.drop_index("idx_jobs_status", table_name="jobs")
    op.drop_index("idx_jobs_service_type", table_name="jobs")
    op.drop_table("jobs")
    op.drop_table("partner_profiles")
    op.drop_table("users")

