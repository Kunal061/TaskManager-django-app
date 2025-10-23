# Random Django Marketplace

This is a sample, moderately complex Django application generated for deployment testing.

Features:
- Marketplace app with products, sellers, orders, reviews
- REST API endpoints (DRF) + basic HTML pages
- Dockerfile + Gunicorn + WhiteNoise static handling
- Tests for models and views

How to run locally (macOS / zsh):

1. Create a virtualenv and install:
```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

2. Migrate and run:
```bash
python manage.py migrate
python manage.py runserver
```

3. Run tests:
```bash
python manage.py test
```

Docker:
Build: `docker build -t random-django-try .`
Run: `docker run -p 8000:8000 random-django-try`

Docker Compose (local PostgreSQL):
1. Copy `.env.sample` to `.env` and edit if needed. Do NOT commit `.env` to git.
2. Start services:
```bash
docker compose up --build
```

CI:
There is a GitHub Actions workflow at `.github/workflows/ci.yml` which runs migrations and tests using a Postgres service.

Development override:
You can use `docker-compose.override.yml` (included) to run the development server with live code mounts:

```bash
docker compose up --build
# or (if you only want the web service): docker compose up web
```

Production settings:
- `randomsite/settings_production.py` reads secrets and DB connection from environment variables. Use `DJANGO_SETTINGS_MODULE=randomsite.settings_production` in production.

Health endpoints:
- `GET /health/` returns basic OK JSON.
- `GET /ready/` returns readiness (checks DB connectivity).

Gunicorn port:
- Docker/Gunicorn is configured to bind to port 8010; compose files map host port 8010 to the container.

Deployment checklist
1. Create a secure SECRET_KEY and set it in the environment: `DJANGO_SECRET_KEY`.
2. Configure `DJANGO_ALLOWED_HOSTS` to your domain(s).
3. Configure a production database (Postgres) env vars: `POSTGRES_DB`, `POSTGRES_USER`, `POSTGRES_PASSWORD`, `DB_HOST`, `DB_PORT`.
4. Collect static files and configure a static/media storage (S3 recommended for large scale).
5. Run migrations during deployment: `python manage.py migrate --noinput`.
6. Use the included `gunicorn.conf.py` to run Gunicorn bound to port 8010.
7. Ensure logging directory exists (`logs/`) and monitor `logs/gunicorn.log` and `logs/django.log`.
8. Configure process manager (systemd, Docker, or your host) and set up healthchecks to `/health/` and `/ready/`.
9. Set up HTTPS and a reverse proxy (Nginx, Traefik) if exposing directly to the internet.

Quick deploy with Docker Compose (example):

```bash
docker compose up --build -d
# Wait for the web service to be healthy and check /ready/ for readiness
```



Notes: This is a generated sample. Secure SECRET_KEY and configure DB for production.

