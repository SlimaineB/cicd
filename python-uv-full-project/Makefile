PY_VERSION=3.12
IMAGE_NAME=local/demo:dev

.PHONY: install dev test lint cov audit bandit secrets docker-build gitlabci-local cleanup

install:
	uv sync --no-dev

local-run:
	uv run uvicorn app.app:app --host 0.0.0.0 --port 8080

precommit-install:
	uv run pre-commit install

precommit-run:
	uv run pre-commit run --all-files

dev:
	uv sync --dev

test:
	uv run pytest -q

cov:
	uv run pytest -q --cov=. --cov-report=term-missing --cov-report=xml:coverage.xml

lint:
	uv run ruff check .

audit:
	uv export --format=requirements.txt > requirements.txt
	uv run pip-audit -r requirements.txt --progress-spinner=off || true
	rm requirements.txt

bandit:
	uv run bandit -q -r app -c pyproject.toml || true

secrets:
	docker run --rm -v $$PWD:/repo -w /repo ghcr.io/trufflesecurity/trufflehog:latest filesystem --no-update --fail --only-verified . || true

docker-build:
	docker build -t $(IMAGE_NAME) .

gitlab-ci-local:
	gitlab-ci-local

cleanup:
	sudo rm -rf .venv requirements.txt coverage.xml junit.xml bandit.json pip-audit.json trufflehog.json

commit:
	git add . && git commit -m "Update Makefile and CI configuration"; git push

all: lint test cov audit bandit secrets
