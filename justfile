default:
    @just --list

# Run the backend local-mode test three times.
backend-test-local:
    cd backend && uv run --group dev pytest tests/test_app_local.py -q --count=3
