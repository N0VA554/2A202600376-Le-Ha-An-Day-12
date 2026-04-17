# Day 12 Lab - Mission Answers

## Part 1: Localhost vs Production

### Exercise 1.1: Anti-patterns found
1. API key hardcode trong code (OPENAI_API_KEY = "sk-hardcoded-fake-key-never-do-this")
2. Không có config management - các giá trị như DEBUG, MAX_TOKENS được hardcode
3. Sử dụng print() thay vì proper logging - print ra secrets và không có structure
4. Không có health check endpoint - platform không biết khi nào restart
5. Port cố định (8000) - không đọc từ environment variable PORT

### Exercise 1.3: Comparison table
| Feature | Develop | Production | Why Important? |
|---------|---------|------------|----------------|
| Config | Hardcode values | Environment variables | Bảo mật secrets, linh hoạt cho khác biệt môi trường |
| Health check | Không có | /health endpoint | Platform biết khi nào restart container |
| Logging | print() statements | JSON structured logging | Dễ parse, monitor và debug trong production |
| Shutdown | Đột ngột | Graceful shutdown với signal handler | Hoàn thành requests đang chạy trước khi tắt |
| Port binding | localhost:8000 | 0.0.0.0:$PORT | Chạy được trong container, PORT từ env |

## Part 2: Docker

### Exercise 2.1: Dockerfile questions
1. Base image: python:3.11-slim
2. Working directory: /app
3. Tại sao COPY requirements.txt trước? Để tận dụng Docker layer caching - nếu requirements.txt không đổi, không cần reinstall dependencies
4. CMD vs ENTRYPOINT: CMD là default command có thể override, ENTRYPOINT là fixed entry point không thể override

### Exercise 2.3: Image size comparison
- Develop: ~1.2 GB (full Python image + dependencies)
- Production: ~150 MB (multi-stage build, chỉ runtime dependencies)
- Difference: ~87% reduction

## Part 3: Cloud Deployment

### Exercise 3.1: Railway deployment
- URL: https://your-app.railway.app (sẽ được cung cấp sau khi deploy)
- Screenshot: [Link to screenshot in repo]

## Part 4: API Security

### Exercise 4.1-4.3: Test results
```
# Test without API key
curl http://localhost:8000/ask -X POST -H "Content-Type: application/json" -d '{"question": "Hello"}'
# Expected: 401 Unauthorized

# Test with valid API key
curl http://localhost:8000/ask -X POST -H "X-API-Key: dev-key-change-me" -H "Content-Type: application/json" -d '{"question": "Hello"}'
# Expected: 200 OK with response

# Test rate limiting (call multiple times quickly)
for i in {1..25}; do curl -s http://localhost:8000/ask -X POST -H "X-API-Key: dev-key-change-me" -H "Content-Type: application/json" -d '{"question": "Test '$i'"}'; done
# Expected: First 20 requests succeed, remaining get 429 Too Many Requests
```

### Exercise 4.4: Cost guard implementation
Implementation uses Redis to track monthly spending per user with key format `budget:{user_id}:{YYYY-MM}`. Each request estimates cost at $0.01 and checks against $10 monthly limit. Budget resets automatically at month start with 32-day TTL to handle month transitions.

## Part 5: Scaling & Reliability

### Exercise 5.1-5.5: Implementation notes
- Health check: `/health` endpoint returns 200 with uptime info
- Readiness check: `/ready` endpoint checks Redis connection, returns 503 if unavailable
- Graceful shutdown: SIGTERM handler completes in-flight requests before exit
- Stateless design: All state stored in Redis (conversation history, budgets, rate limits)
- Load balancing: Docker Compose scales agent to 3 instances behind Nginx
- Test results: Stateless test passes - conversations persist across instance restarts</content>
<parameter name="filePath">d:\AI_thuc_chien\day12_ha-tang-cloud_va_deployment\MISSION_ANSWERS.md