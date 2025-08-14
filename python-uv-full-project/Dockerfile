# Stage build
FROM ghcr.io/astral-sh/uv:python3.12-bookworm AS build
WORKDIR /app

# Copie des manifests pour profiter du cache
COPY pyproject.toml uv.lock* ./
RUN uv sync --frozen --no-dev || uv sync --no-dev

# Copie du code
COPY . .

# Stage runtime minimal, non-root
FROM python:3.12-slim
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    VIRTUAL_ENV=/app/.venv \
    PATH="/app/.venv/bin:$PATH"
WORKDIR /app

# Dépendances système minimales
RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Copier l'environnement virtuel et le code
COPY --from=build /app/.venv /app/.venv
COPY . .

# Créer un utilisateur non-root
RUN useradd -r -u 10001 appuser && chown -R appuser:appuser /app
USER appuser

EXPOSE 8080
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8080"]
