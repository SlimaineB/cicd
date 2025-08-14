PY_VERSION=3.12
IMAGE_NAME=local/demo:dev

.PHONY: install dev test lint cov audit bandit secrets docker-build

install:
	uv sync --no-dev

dev:
	uv sync --dev

test:
	uv run pytest -q

cov:
	uv run pytest -q --cov=. --cov-report=term-missing --cov-report=xml:coverage.xml

lint:
	uv run ruff check .

audit:
	uv run pip-audit -r <(uv export --format=requirements) --progress-spinner=off || true

bandit:
	uv run bandit -q -r . -c pyproject.toml || true

secrets:
	docker run --rm -v $$PWD:/repo -w /repo ghcr.io/trufflesecurity/trufflehog:latest filesystem --no-update --fail --only-verified . || true

docker-build:
	docker build -t $(IMAGE_NAME) .
