"""Rate Limiting with Sliding Window"""
import time
import redis
from fastapi import HTTPException
from app.config import settings

# Use Redis if available, otherwise in-memory
if settings.redis_url:
    r = redis.from_url(settings.redis_url)
else:
    r = None

# In-memory fallback
_rate_limits = {}

def check_rate_limit(user_id: str):
    """Check if user has exceeded rate limit"""
    if not r:
        # In-memory implementation
        now = time.time()
        if user_id not in _rate_limits:
            _rate_limits[user_id] = []

        # Clean old requests (older than 1 minute)
        _rate_limits[user_id] = [t for t in _rate_limits[user_id] if now - t < 60]

        if len(_rate_limits[user_id]) >= settings.rate_limit_per_minute:
            raise HTTPException(status_code=429, detail="Rate limit exceeded")

        _rate_limits[user_id].append(now)
        return

    # Redis implementation
    key = f"rate_limit:{user_id}"
    now = time.time()

    # Add current request
    r.zadd(key, {str(now): now})

    # Remove requests older than 1 minute
    r.zremrangebyscore(key, 0, now - 60)

    # Count remaining requests
    count = r.zcard(key)

    if count > settings.rate_limit_per_minute:
        raise HTTPException(status_code=429, detail="Rate limit exceeded")

    # Expire key after 1 minute
    r.expire(key, 60)