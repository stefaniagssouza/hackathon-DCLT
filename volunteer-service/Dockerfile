FROM python:3.11-slim AS runtime

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

WORKDIR /app

RUN useradd --create-home --shell /usr/sbin/nologin appuser

COPY requirements.txt .
RUN pip install --upgrade pip \
    && pip install -r requirements.txt

COPY app.py ./app.py

USER appuser
EXPOSE 8083
CMD ["opentelemetry-instrument", "gunicorn", "--bind", "0.0.0.0:8083", "--workers", "2", "--threads", "2", "app:app"]
