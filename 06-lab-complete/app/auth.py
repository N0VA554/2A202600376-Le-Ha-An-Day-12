"""API Key Authentication"""
from fastapi import HTTPException, Security
from fastapi.security.api_key import APIKeyHeader
from app.config import settings

api_key_header = APIKeyHeader(name="X-API-Key", auto_error=False)

def verify_api_key(api_key: str = Security(api_key_header)) -> str:
    """Verify API key and return user_id"""
    if not api_key:
        raise HTTPException(status_code=401, detail="API key required")

    if api_key != settings.agent_api_key:
        raise HTTPException(status_code=401, detail="Invalid API key")

    # For simplicity, return a fixed user_id. In real app, decode from JWT
    return "user1"