#!/usr/bin/env bash
set -e

echo "Waiting for database..."
while ! pg_isready -h "$DB_HOST" -p "$DB_PORT" -U "$POSTGRES_USER" >/dev/null 2>&1; do
  sleep 1
done

echo "Running migrations..."
python manage.py migrate --noinput
echo "Collecting static files..."
python manage.py collectstatic --noinput || true

# Ensure logs dir exists for Gunicorn
mkdir -p /app/logs

exec "$@"
