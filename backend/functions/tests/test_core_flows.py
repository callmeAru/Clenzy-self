from fastapi.testclient import TestClient

from main import app


client = TestClient(app)


def test_root_healthcheck():
    response = client.get("/")
    assert response.status_code == 200
    body = response.json()
    assert "message" in body


def test_signup_and_login_flow():
    # Use a unique email per test run
    email = "test_user@example.com"
    phone = "1234567890"
    password = "testpassword123"

    signup_payload = {
        "full_name": "Test User",
        "email": email,
        "phone": phone,
        "password": password,
    }

    resp = client.post("/api/users/signup", json=signup_payload)
    assert resp.status_code in (200, 201), resp.text

    login_payload = {"email": email, "password": password}
    resp = client.post("/api/users/login", data=login_payload)
    assert resp.status_code == 200, resp.text

    data = resp.json()
    assert "access_token" in data
    assert data.get("token_type") == "bearer"

