# ⚡ Commands Cheat Sheet

**Quick copy-paste commands for Django Task Manager deployment**

---

## 🚀 Initial Deployment on EC2

```bash
# Method 1: Automated (Easiest)
cd random-django-app && git pull && ./deploy-sqlite.sh

# Method 2: Manual
cd random-django-app
git pull
docker-compose down
docker-compose up -d web
sleep 10
docker-compose exec web python manage.py migrate
docker-compose exec web python manage.py createsuperuser
docker-compose exec web python manage.py collectstatic --noinput
docker-compose ps
```

---

## 🔄 Update Deployment

```bash
cd random-django-app && git pull && docker-compose restart web
```

---

## 📊 Check Status

```bash
# Container status
docker-compose ps

# View logs
docker-compose logs -f web

# Test locally
curl http://localhost:9000
```

---

## 🛠️ Common Commands

```bash
# Restart
docker-compose restart web

# Rebuild
docker-compose up -d --build web

# Stop
docker-compose down

# Start
docker-compose up -d web
```

---

## 🐛 Troubleshooting

```bash
# Check errors
docker-compose logs web | grep -i error

# Full restart
docker-compose down && docker-compose up -d web

# Clean rebuild
docker-compose down -v && docker-compose up -d --build web
```

---

## 🌐 Access

- **App:** http://13.233.122.241:9000
- **Admin:** http://13.233.122.241:9000/admin

---

**Full Guide:** [DEPLOY_COMMANDS.md](DEPLOY_COMMANDS.md)
