FROM python:3.11-slim
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1
WORKDIR /app
COPY requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt
COPY . /app
ENV DJANGO_SETTINGS_MODULE=randomsite.settings
RUN chmod +x /app/entrypoint.sh || true
RUN python manage.py collectstatic --noinput || true
ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["gunicorn", "randomsite.wsgi:application", "--bind", "0.0.0.0:8010", "--workers", "3"]
