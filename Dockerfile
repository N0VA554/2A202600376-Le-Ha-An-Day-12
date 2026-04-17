# Stage 1: Builder
FROM python:3.11-slim AS builder
WORKDIR /build
RUN apt-get update && apt-get install -y gcc libpq-dev && rm -rf /var/lib/apt/lists/*

# Copy requirements từ thư mục lab
COPY 06-lab-complete/requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

# Stage 2: Runtime
FROM python:3.11-slim AS runtime

# Tạo user agent và đặt Home là /app luôn cho đồng nhất
RUN groupadd -r agent && useradd -r -g agent -d /app agent
WORKDIR /app

# Copy thư viện vào đúng thư mục home của user (/app/.local)
COPY --from=builder /root/.local /app/.local

# Copy application code
COPY 06-lab-complete/app/ ./app/
COPY utils/ ./utils/
COPY 06-lab-complete/start.sh ./start.sh

# Cấp quyền cho user agent
RUN chown -R agent:agent /app && chmod +x ./start.sh

USER agent

# Cập nhật PATH chuẩn xác theo WORKDIR
ENV PATH=/app/.local/bin:$PATH
ENV PYTHONPATH=/app
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Railway sẽ gán cổng ngẫu nhiên qua biến PORT, mặc định là 8000 nếu test local
ENV PORT=8000
EXPOSE 8000

# Health check: Sử dụng biến môi trường PORT để tránh lỗi mismatch
HEALTHCHECK --interval=30s --timeout=10s --start-period=15s --retries=3 \
    CMD python -c \
    "import urllib.request; import os; port = os.getenv('PORT', '8000'); urllib.request.urlopen(f'http://localhost:{port}/health')" \
    || exit 1

# QUAN TRỌNG: Dùng shell form để uvicorn nhận được biến $PORT từ Railway
CMD ["sh", "-c", "uvicorn app.main:app --host 0.0.0.0 --port ${PORT:-8000} --workers 2"]