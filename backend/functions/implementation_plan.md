# Implementation Plan - Clenzy Home Services SaaS

This plan outlines the steps to build Clenzy, a real-world home-services platform with risk-aware dispatch and dual-side safety features.

## Proposed Changes

### Project Structure [NEW]

We will initialize a monorepo-style structure:
- `/frontend_customer_flutter`: Customer-facing mobile app.
- `/frontend_employee_flutter`: Worker-facing mobile app.
- `/admin_panel_flutter_web`: Admin dashboard for management and dispatch.
- `/backend_flask`: Core REST API and business logic.
- `/realtime_engine`: Socket.io integration for tracking and chat.
- `/ml_services`: Python microservices for risk scoring and forecasting.
- `/database_schema`: SQL scripts and migration files.
- `/security_modules`: Auth, encryption, and audit logging.
- `/infra_deployment`: Docker and Kubernetes configurations.
- `/devops_ci_cd`: GitHub Actions workflows.

---

### Backend Layer (Flask) [NEW]

#### [NEW] [backend_flask/](file:///e:/project%20clenzy/backend_flask/)
- Modular architecture with blueprints for `auth`, `bookings`, `workers`, `users`, `panic`, etc.
- JWT authentication with role-based access control.
- Integration with MySQL using SQLAlchemy or raw SQL for performance.
- Logging and monitoring middleware.

---

### Database Layer (MySQL) [NEW]

#### [NEW] [database_schema/schema.sql](file:///e:/project%20clenzy/database_schema/schema.sql)
- Comprehensive schema design including:
  - `users`, `workers`, `bookings`, `dispatch_logs`, `panic_alerts`, `risk_factors`, `feedback`, `payments`.
  - Indexes for fast proximity-based worker search.

---

### ML Microservices [NEW]

#### [NEW] [ml_services/](file:///e:/project%20clenzy/ml_services/)
- `risk_prediction`: Placeholder ML model for CRADE (Contextual Risk-Aware Dispatch Engine).
- `sentiment_analysis`: NLP for feedback processing.
- `demand_forecasting`: Time-series forecasting stub.

---

### Frontend Layer (Flutter) [NEW]

#### [NEW] [frontend_customer_flutter/](file:///e:/project%20clenzy/frontend_customer_flutter/)
- Clean architecture with BLoC or Provider for state management.
- Integration with Google Maps for tracking.
- SafeTap Panic button (silent trigger).

#### [NEW] [frontend_employee_flutter/](file:///e:/project%20clenzy/frontend_employee_flutter/)
- Job feed with real-time push notifications.
- Background location tracking for dispatch accuracy.

---

### Security and Safety [NEW]

- **SafeTap System**: Silent panic triggers handled via background services.
- **CRADE Engine**: Advanced worker assignment logic based on risk scores (customer history, time, location).

---

### DevOps [NEW]

#### [NEW] [infra_deployment/docker-compose.yml](file:///e:/project%20clenzy/infra_deployment/docker-compose.yml)
- Orchestration for local development.

#### [NEW] [devops_ci_cd/.github/workflows/](file:///e:/project%20clenzy/devops_ci_cd/.github/workflows/)
- CI/CD pipelines for linting and deployment.

## Verification Plan

### Automated Tests
- Pytest for backend API endpoints.
- Flutter widget and unit tests for apps.
- Linting checks (flake8 for Python, flutter analyze for Flutter).

### Manual Verification
- Testing the end-to-end booking flow from customer app to worker app.
- Verifying panic alerts appear in the admin dashboard.
- Checking real-time location tracking on the map.
