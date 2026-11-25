"""Local-mode tests for the Flask application's public HTTP interface."""

from backend.app import JOKES, app


def test_local_root_returns_a_joke_and_server_hostname(monkeypatch):
    monkeypatch.setattr("backend.app.random.choice", lambda jokes: jokes[0])
    monkeypatch.setattr("backend.app.socket.gethostname", lambda: "local-test-host")

    response = app.test_client().get("/")

    assert response.status_code == 200
    assert response.mimetype == "text/html"
    assert response.get_data(as_text=True) == (
        f"{JOKES[0]}\n(Served by: local-test-host)\n"
    )


def test_health_returns_ok():
    response = app.test_client().get("/health")

    assert response.status_code == 200
    assert response.get_data(as_text=True) == "Ok"


def test_health_hostname_returns_only_the_hostname_marker(monkeypatch):
    monkeypatch.setattr("backend.app.socket.gethostname", lambda: "local-test-host")

    response = app.test_client().get("/health/hostname")

    assert response.status_code == 200
    assert response.get_data(as_text=True) == "(Served by: local-test-host)\n"
