"""Cost Guard - Monthly Budget Protection"""
import redis
from datetime import datetime
from fastapi import HTTPException
from app.config import settings

# Use Redis if available, otherwise in-memory
if settings.redis_url:
    r = redis.from_url(settings.redis_url)
else:
    r = None

# In-memory fallback
_budgets = {}

def check_budget(user_id: str, estimated_cost: float = 0.01):
    """Check if user has budget remaining for this month"""
    month_key = datetime.now().strftime("%Y-%m")
    key = f"budget:{user_id}:{month_key}"

    if not r:
        # In-memory implementation
        if key not in _budgets:
            _budgets[key] = 0.0

        if _budgets[key] + estimated_cost > settings.daily_budget_usd:
            raise HTTPException(status_code=402, detail="Monthly budget exceeded")

        _budgets[key] += estimated_cost
        return

    # Redis implementation
    current = float(r.get(key) or 0)

    if current + estimated_cost > settings.daily_budget_usd:
        raise HTTPException(status_code=402, detail="Monthly budget exceeded")

    r.incrbyfloat(key, estimated_cost)
    # Expire after 32 days (covers month rollover)
    r.expire(key, 32 * 24 * 3600)