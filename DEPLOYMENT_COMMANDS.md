# 🚀 Django Task Manager - Deployment Commands Guide

This file contains all the commands you need to deploy and manage the Django Task Manager on EC2.

---

## 📋 Table of Contents

1. [Quick Deployment](#quick-deployment)
2. [Manual Step-by-Step Deployment](#manual-step-by-step-deployment)
3. [Complete One-Liner](#complete-one-liner)
4. [Troubleshooting Commands](#troubleshooting-commands)
5. [Monitoring Commands](#monitoring-commands)
6. [Update/Redeploy Commands](#updateredeploy-commands)
7. [Emergency Commands](#emergency-commands)

---

## 🎯 Quick Deployment

### Method 1: Automated Script (Recommended)

```bash
# On EC2
cd random-django-app
git pull
./deploy-sqlite.sh
```

**What this does:**
- Pulls latest code from GitHub
- Stops all containers
- Starts web container
- Runs migrations
- Collects static files
- Creates superuser (interactive)
- Shows deployment status

---

## 🔧 Manual Step-by-Step Deployment

### Method 2: Run Commands Manually

```bash
# Navigate to project
cd random-django-app

# Get latest code
git pull

# Stop everything
docker-compose down

# Start only web (no database container needed)
docker-compose up -d web

# Wait for container to be ready
sleep 10

# Run migrations (will work instantly with SQLite!)
docker-compose exec web python manage.py migrate

# Create superuser
docker-compose exec web python manage.py createsuperuser

# Collect static files
docker-compose exec web python manage.py collectstatic --noinput

# Check status
docker-compose ps
```

---

## ⚡ Complete One-Liner

### Full Deployment in One Command

```bash
cd random-django-app && git pull && docker-compose down && docker-compose up -d web && sleep 10 && docker-compose exec web python manage.py migrate && docker-compose exec web python manage.py collectstatic --noinput && docker-compose exec web python manage.py createsuperuser && docker-compose ps
```

### Without Superuser Creation (for updates)

```bash
cd random-django-app && git pull && docker-compose down && docker-compose up -d web && sleep 10 && docker-compose exec web python manage.py migrate && docker-compose exec web python manage.py collectstatic --noinput && docker-compose ps
```

---

## 🐛 Troubleshooting Commands

### Check Container Status

```bash
# List all containers
docker-compose ps

# Detailed container info
docker ps -a

# Check if web container is running
docker-compose ps web
```

### View Logs

```bash
# View real-time logs
docker-compose logs -f web

# View last 100 lines
docker-compose logs --tail=100 web

# View logs with timestamps
docker-compose logs -f -t web

# Search for errors
docker-compose logs web | grep -i error
docker-compose logs web | grep -i exception
```

### Test Application

```bash
# Test from EC2 instance itself
curl http://13.233.122.241:9000

# Check if port 9000 is listening
sudo netstat -tulpn | grep 9000

# Alternative port check
sudo lsof -i :9000
```

### Database Commands

```bash
# Open Django shell
docker-compose exec web python manage.py shell

# Check database migrations
docker-compose exec web python manage.py showmigrations

# Create new migration
docker-compose exec web python manage.py makemigrations

# Apply migrations
docker-compose exec web python manage.py migrate
```

### Access Container Shell

```bash
# Enter the web container
docker-compose exec web bash

# Once inside, you can run:
python manage.py shell
python manage.py dbshell
ls -la /app/
cat /app/db.sqlite3
```

---

## 📊 Monitoring Commands

### Real-time Monitoring

```bash
# Monitor container stats (CPU, Memory, Network)
docker stats

# Monitor only web container
docker stats random-django-app-web-1

# Watch logs continuously
watch -n 2 'docker-compose logs --tail=20 web'
```

### Health Checks

```bash
# Check Docker service
sudo systemctl status docker

# Check disk space
df -h

# Check memory usage
free -m

# Check running processes
ps aux | grep gunicorn
```

### Application Status

```bash
# Check Django version
docker-compose exec web python manage.py version

# List installed packages
docker-compose exec web pip list

# Check static files
docker-compose exec web ls -la /app/staticfiles/
```

---

## 🔄 Update/Redeploy Commands

### Quick Update (No Code Changes)

```bash
# Just restart the container
docker-compose restart web
```

### Update with New Code

```bash
# Pull latest code and restart
cd random-django-app
git pull
docker-compose restart web
```

### Update with Database Changes

```bash
# Pull code, run migrations, restart
cd random-django-app
git pull
docker-compose exec web python manage.py migrate
docker-compose restart web
```

### Full Rebuild (if Dockerfile changed)

```bash
cd random-django-app
git pull
docker-compose down
docker-compose build --no-cache
docker-compose up -d web
sleep 10
docker-compose exec web python manage.py migrate
docker-compose exec web python manage.py collectstatic --noinput
```

---

## 🆘 Emergency Commands

### Complete Reset (Careful!)

```bash
# Stop everything and remove containers
docker-compose down

# Remove all images (forces rebuild)
docker-compose down --rmi all

# Remove volumes too (DELETES DATABASE!)
docker-compose down -v

# Nuclear option - remove everything Docker
docker system prune -a
```

### Fix Permission Issues

```bash
# Fix file permissions
sudo chown -R $USER:$USER random-django-app/
chmod +x random-django-app/*.sh
```

### Fix Docker Issues

```bash
# Restart Docker service
sudo systemctl restart docker

# Check Docker daemon
sudo systemctl status docker

# View Docker logs
sudo journalctl -u docker
```

### Restore from Backup

```bash
# Stop containers
docker-compose down

# Restore database (if you have backup)
cp backup/db.sqlite3 db.sqlite3

# Start again
docker-compose up -d web
```

---

## 📝 Post-Deployment Verification

### Check Everything is Working

```bash
# 1. Container is running
docker-compose ps

# 2. Application responds
curl http://13.233.122.241:9000

# 3. Admin panel works
curl http://13.233.122.241:9000/admin/

# 4. Static files load
curl http://13.233.122.241:9000/static/css/style.css

# 5. Check logs for errors
docker-compose logs web | grep -i error
```

### Access the Application

```bash
# From browser or curl, access:
http://13.233.122.241:9000/          # Home page
http://13.233.122.241:9000/admin/    # Admin panel
http://13.233.122.241:9000/tasks/    # Task list

# Test with curl on EC2:
curl http://13.233.122.241:9000/
curl http://13.233.122.241:9000/admin/
curl http://13.233.122.241:9000/tasks/
```

---

## 🔐 Security Reminders

### Before Production Deployment

```bash
# 1. Change SECRET_KEY in .env
echo "SECRET_KEY=$(python -c 'from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())')" >> .env

# 2. Set DEBUG=False in .env
sed -i 's/DEBUG=True/DEBUG=False/' .env

# 3. Update ALLOWED_HOSTS in .env
echo "ALLOWED_HOSTS=13.233.122.241,your-domain.com" >> .env

# 4. Restart after changes
docker-compose restart web
```

---

## 📞 Quick Reference

| Action | Command |
|--------|---------|
| **Deploy** | `cd random-django-app && ./deploy-sqlite.sh` |
| **Update** | `git pull && docker-compose restart web` |
| **View Logs** | `docker-compose logs -f web` |
| **Check Status** | `docker-compose ps` |
| **Stop** | `docker-compose down` |
| **Start** | `docker-compose up -d web` |
| **Restart** | `docker-compose restart web` |
| **Shell** | `docker-compose exec web bash` |
| **Django Shell** | `docker-compose exec web python manage.py shell` |
| **Migrations** | `docker-compose exec web python manage.py migrate` |

---

## 🎓 Tips

1. **Always pull before deploying**: `git pull` ensures you have the latest code
2. **Check logs if something fails**: `docker-compose logs -f web`
3. **Use automated script for first deployment**: `./deploy-sqlite.sh`
4. **Use restart for quick updates**: `docker-compose restart web`
5. **Monitor EC2 Security Group**: Ensure port 9000 is open in AWS Security Group settings

---

## 📌 Common Workflows

### First Time Setup
```bash
cd random-django-app
git pull
./deploy-sqlite.sh
```

### Regular Updates
```bash
cd random-django-app
git pull
docker-compose restart web
```

### With Database Changes
```bash
cd random-django-app
git pull
docker-compose exec web python manage.py migrate
docker-compose restart web
```

### Complete Rebuild
```bash
cd random-django-app
git pull
docker-compose down
docker-compose up -d web
sleep 10
docker-compose exec web python manage.py migrate
docker-compose exec web python manage.py collectstatic --noinput
```

---

**✅ Your application will be accessible at: http://13.233.122.241:9000**

**🎉 Happy Deploying!**
