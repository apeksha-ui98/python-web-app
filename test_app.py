from app import app

def test_home():
    client = app.test_client()
    response = client.get("/home")

    assert response.status_code == 200
    assert "text/html" in response.content_type