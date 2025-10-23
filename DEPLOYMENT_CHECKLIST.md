# 🚀 EC2 Deployment Checklist - READY TO DEPLOY

## ✅ Pre-Deployment Verification (All Complete!)

### Configuration Files
- [x] Dockerfile configured for port 9000
- [x] docker-compose.yml configured for port 9000
- [x] .env.example template ready
- [x] .gitignore properly configured (excludes .env)
- [x] requirements.txt includes all dependencies
- [x] Django settings use environment variables

### Port Configuration
- [x] Port 9000 configured in Dockerfile
- [x] Port 9000 exposed in docker-compose.yml
- [x] Gunicorn bound to 0.0.0.0:9000

### EC2 Details
- **EC2 IP:** 13.233.122.241
- **Port:** 9000
- **Access URL:** http://13.233.122.241:9000

---

## 📋 Step-by-Step Deployment Instructions

### 1️⃣ EC2 Instance Setup

**Security Group Configuration:**
```
Inbound Rules:
├─ SSH (22) - Your IP or 0.0.0.0/0
└─ Custom TCP (9000) - 0.0.0.0/0 (for public access)
```

**Connect to EC2:**
```bash
ssh -i your-key.pem ec2-user@13.233.122.241
# or for Ubuntu
ssh -i your-key.pem ubuntu@13.233.122.241
```

---

### 2️⃣ Install Docker & Dependencies (Amazon Linux 2023)

```bash
# Update system
sudo yum update -y

# Install Docker
sudo yum install docker -y
sudo service docker start
sudo usermod -a -G docker ec2-user

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Install Git
sudo yum install git -y

# IMPORTANT: Log out and log back in for Docker permissions
exit
```

**Reconnect:**
```bash
ssh -i your-key.pem ec2-user@13.233.122.241
```

**Verify installations:**
```bash
docker --version
docker-compose --version
git --version
```

---

### 3️⃣ Clone and Configure Application

```bash
# Clone from GitHub (replace with your repo URL)
git clone https://github.com/Kunal061/random-django-app.git
cd random-django-app

# Copy and edit environment file
cp .env.example .env
nano .env
```

**Update .env file with these values:**
```env
SECRET_KEY=<GENERATE-NEW-KEY-SEE-BELOW>
DEBUG=False
ALLOWED_HOSTS=13.233.122.241,localhost,127.0.0.1

DB_ENGINE=django.db.backends.postgresql
DB_NAME=taskmanager_db
DB_USER=taskmanager_user
DB_PASSWORD=<STRONG-SECURE-PASSWORD>
DB_HOST=db
DB_PORT=5432
```

**Generate SECRET_KEY:**
```bash
python3 -c 'from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())'
```

Copy the output and paste it as SECRET_KEY in .env file.

---

### 4️⃣ Build and Start Application

```bash
# Build and start containers
docker-compose up -d --build

# Wait for containers to start (30 seconds)
sleep 30

# Check container status
docker-compose ps
```

**Expected output:**
```
NAME                COMMAND                  SERVICE   STATUS    PORTS
random-django-app-db-1    "docker-entrypoint.s…"   db        Up        5432/tcp
random-django-app-web-1   "gunicorn --bind 0.0…"   web       Up        0.0.0.0:9000->9000/tcp
```

---

### 5️⃣ Database Setup

```bash
# Run migrations
docker-compose exec web python manage.py migrate

# Create superuser for admin access
docker-compose exec web python manage.py createsuperuser
```

**Superuser prompts:**
- Username: (your choice, e.g., admin)
- Email: kunalr.tech@gmail.com
- Password: (create a secure password)

---

### 6️⃣ Collect Static Files (if needed)

```bash
docker-compose exec web python manage.py collectstatic --noinput
```

---

### 7️⃣ Verify Deployment

**Check logs:**
```bash
docker-compose logs -f web
```

**Test application locally on EC2:**
```bash
curl http://localhost:9000
```

**Access from browser:**
- Main App: http://13.233.122.241:9000
- Admin Panel: http://13.233.122.241:9000/admin

---

## 🔒 Security Checklist

Before going live, ensure:
- [ ] **SECRET_KEY** - Generated new key (not default)
- [ ] **DEBUG** - Set to False
- [ ] **ALLOWED_HOSTS** - Contains EC2 IP (13.233.122.241)
- [ ] **DB_PASSWORD** - Changed to strong password
- [ ] **EC2 Security Group** - Port 9000 allowed
- [ ] **Superuser Created** - For admin access
- [ ] **.env file** - Not committed to Git (in .gitignore)

---

## 🛠️ Essential Commands Reference

### Application Management
```bash
# Start application
docker-compose up -d

# Stop application
docker-compose down

# Restart application
docker-compose restart

# View logs (follow mode)
docker-compose logs -f

# View only web logs
docker-compose logs -f web

# Rebuild and restart
docker-compose up -d --build
```

### Django Management
```bash
# Run migrations
docker-compose exec web python manage.py migrate

# Create superuser
docker-compose exec web python manage.py createsuperuser

# Django shell
docker-compose exec web python manage.py shell

# Collect static files
docker-compose exec web python manage.py collectstatic
```

### Database Management
```bash
# Access PostgreSQL shell
docker-compose exec db psql -U taskmanager_user -d taskmanager_db

# Backup database
docker-compose exec db pg_dump -U taskmanager_user taskmanager_db > backup_$(date +%Y%m%d).sql

# Restore database
cat backup_20251024.sql | docker-compose exec -T db psql -U taskmanager_user taskmanager_db
```

### Container Management
```bash
# Check container status
docker-compose ps

# Check resource usage
docker stats

# Access web container shell
docker-compose exec web bash

# Access db container shell
docker-compose exec db sh
```

---

## 🔍 Troubleshooting

### Application not accessible from browser

**Check Security Group:**
- Ensure port 9000 is open in EC2 Security Group
- Inbound rule: Custom TCP, Port 9000, Source 0.0.0.0/0

**Check containers:**
```bash
docker-compose ps
# Both web and db should show "Up"
```

**Check logs:**
```bash
docker-compose logs web
docker-compose logs db
```

### Database connection errors

```bash
# Check database is ready
docker-compose exec db pg_isready

# Restart database
docker-compose restart db

# Check database logs
docker-compose logs db
```

### Static files not loading

```bash
docker-compose exec web python manage.py collectstatic --noinput
docker-compose restart web
```

### Permission denied (Docker)

```bash
sudo usermod -aG docker $USER
# Log out and back in
```

### Port already in use

```bash
# Check what's using port 9000
sudo lsof -i :9000

# Stop the application
docker-compose down

# Start again
docker-compose up -d
```

---

## 📊 Post-Deployment Verification

### 1. Test Main Application
- Visit: http://13.233.122.241:9000
- Should see task list page
- Try creating a task

### 2. Test Admin Panel
- Visit: http://13.233.122.241:9000/admin
- Login with superuser credentials
- Verify you can manage tasks

### 3. Check Logs
```bash
docker-compose logs --tail=50 web
```
Should show no errors

### 4. Monitor Resources
```bash
docker stats
```
Check CPU and memory usage

---

## 🎯 Success Indicators

✅ Containers running: `docker-compose ps` shows both web and db as "Up"
✅ Application accessible: http://13.233.122.241:9000 loads
✅ Admin works: http://13.233.122.241:9000/admin accessible
✅ Tasks work: Can create, edit, delete tasks
✅ No errors in logs: `docker-compose logs` shows clean output
✅ Database persists: Tasks remain after restart

---

## 📞 Quick Reference

| Item | Value |
|------|-------|
| EC2 IP | 13.233.122.241 |
| Port | 9000 |
| Main URL | http://13.233.122.241:9000 |
| Admin URL | http://13.233.122.241:9000/admin |
| Database | PostgreSQL 15 (in container) |
| App Server | Gunicorn (3 workers) |
| Framework | Django 4.2.7 |

---

## 🔄 Update Deployment

When you push changes to GitHub:

```bash
# On EC2
cd random-django-app
git pull
docker-compose down
docker-compose up -d --build
docker-compose exec web python manage.py migrate
docker-compose exec web python manage.py collectstatic --noinput
```

---

## 🎉 You're Ready to Deploy!

**One-command deployment:**
```bash
git clone https://github.com/Kunal061/random-django-app.git && \
cd random-django-app && \
cp .env.example .env && \
echo "⚠️  Edit .env now - set SECRET_KEY, DEBUG=False, and DB_PASSWORD" && \
nano .env
```

**After editing .env:**
```bash
docker-compose up -d --build && \
sleep 30 && \
docker-compose exec web python manage.py migrate && \
docker-compose exec web python manage.py createsuperuser && \
echo "🎉 Deployment complete! Access at http://13.233.122.241:9000"
```

---

**Author:** Kunal Rohilla  
**Email:** kunalr.tech@gmail.com  
**GitHub:** https://github.com/Kunal061  
**Deployment Date:** 2025-10-24
