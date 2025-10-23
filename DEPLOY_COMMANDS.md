# 🚀 Deployment Commands Guide

**Quick reference for deploying Django Task Manager on EC2**

---

## 📋 Prerequisites

Before running these commands, ensure:
- ✅ EC2 instance is running (IP: 13.233.122.241)
- ✅ Docker is installed and running
- ✅ Docker Compose is installed
- ✅ Git is installed
- ✅ Security Group allows port 9000
- ✅ SSH access configured

---

## 🎯 Method 1: Automated Deployment (Recommended)

### **Step 1: SSH into EC2**
```bash
ssh -i your-key.pem ec2-user@13.233.122.241
# Or for Ubuntu
ssh -i your-key.pem ubuntu@13.233.122.241
```

### **Step 2: Navigate and Update**
```bash
cd random-django-app
git pull
```

### **Step 3: Run Deployment Script**
```bash
./deploy-sqlite.sh
```

**That's it! The script handles everything automatically.**

---

## ⚡ Method 2: Manual Deployment (Step-by-Step)

### **Step 1: SSH into EC2**
```bash
ssh -i your-key.pem ec2-user@13.233.122.241
```

### **Step 2: Navigate to Project**
```bash
cd random-django-app
```

### **Step 3: Pull Latest Changes**
```bash
git pull
```

### **Step 4: Stop Existing Containers**
```bash
docker-compose down
```

### **Step 5: Start Web Container**
```bash
docker-compose up -d web
```

### **Step 6: Wait for Container to Start**
```bash
sleep 10
```

### **Step 7: Run Database Migrations**
```bash
docker-compose exec web python manage.py migrate
```

**Expected Output:**
```
Operations to perform:
  Apply all migrations: admin, auth, contenttypes, sessions, tasks
Running migrations:
  Applying contenttypes.0001_initial... OK
  Applying auth.0001_initial... OK
  Applying admin.0001_initial... OK
  ...
  Applying tasks.0001_initial... OK
```

### **Step 8: Create Superuser**
```bash
docker-compose exec web python manage.py createsuperuser
```

**You'll be prompted for:**
- Username: (e.g., admin)
- Email: kunalr.tech@gmail.com
- Password: (enter your password)
- Password (again): (confirm password)

### **Step 9: Collect Static Files**
```bash
docker-compose exec web python manage.py collectstatic --noinput
```

**Expected Output:**
```
120 static files copied to '/app/staticfiles'.
```

### **Step 10: Check Container Status**
```bash
docker-compose ps
```

**Expected Output:**
```
NAME                          COMMAND                  SERVICE   STATUS    PORTS
random-django-app-web-1       "gunicorn --bind 0.0…"   web       Up        0.0.0.0:9000->9000/tcp
```

---

## 📝 Complete One-Liner Command

Copy and paste this entire block on EC2:

```bash
cd random-django-app && \
git pull && \
docker-compose down && \
docker-compose up -d web && \
sleep 10 && \
docker-compose exec web python manage.py migrate && \
docker-compose exec web python manage.py collectstatic --noinput && \
echo "✅ Deployment complete! Create superuser now:" && \
docker-compose exec web python manage.py createsuperuser
```

---

## 🔄 Update Deployment (After Code Changes)

When you push new code to GitHub:

```bash
# On EC2
cd random-django-app
git pull
docker-compose restart web
docker-compose exec web python manage.py migrate
docker-compose exec web python manage.py collectstatic --noinput
```

---

## 🛠️ Useful Management Commands

### View Logs
```bash
# Follow logs in real-time
docker-compose logs -f web

# View last 50 lines
docker-compose logs --tail=50 web

# View logs from specific time
docker-compose logs --since 10m web
```

### Restart Application
```bash
# Restart web container
docker-compose restart web

# Restart with rebuild
docker-compose up -d --build web
```

### Access Container Shell
```bash
# Bash shell
docker-compose exec web bash

# Python Django shell
docker-compose exec web python manage.py shell
```

### Database Management
```bash
# Create new migrations
docker-compose exec web python manage.py makemigrations

# Apply migrations
docker-compose exec web python manage.py migrate

# Show migrations status
docker-compose exec web python manage.py showmigrations
```

### Static Files
```bash
# Collect static files
docker-compose exec web python manage.py collectstatic

# With confirmation
docker-compose exec web python manage.py collectstatic --noinput
```

---

## 🔍 Troubleshooting Commands

### Check if Application is Running
```bash
# Check container status
docker-compose ps

# Check if port 9000 is listening
sudo netstat -tlnp | grep 9000

# Test locally on EC2
curl http://localhost:9000
```

### View Application Errors
```bash
# Check web container logs
docker-compose logs web | grep -i error

# Check last 100 lines
docker-compose logs --tail=100 web
```

### Container Health Check
```bash
# Check container resource usage
docker stats random-django-app-web-1

# Check all containers
docker ps -a

# Inspect container
docker inspect random-django-app-web-1
```

### Clean Up (If Issues Persist)
```bash
# Stop and remove containers
docker-compose down

# Remove volumes
docker-compose down -v

# Clean Docker system
docker system prune -f

# Rebuild from scratch
docker-compose up -d --build web
```

---

## 🎯 Access Your Application

After successful deployment:

- **Main Application:** http://13.233.122.241:9000
- **Admin Panel:** http://13.233.122.241:9000/admin

---

## ✅ Post-Deployment Verification

Run these commands to verify everything is working:

```bash
# 1. Check container is running
docker-compose ps

# 2. Check application responds
curl -I http://localhost:9000

# 3. Check logs for errors
docker-compose logs web | grep -i error

# 4. Test admin access
curl -I http://localhost:9000/admin
```

**All should return 200 OK responses.**

---

## 🔐 Production Checklist

Before going live, ensure:

```bash
# Check environment variables
docker-compose exec web env | grep -E 'DEBUG|SECRET_KEY|ALLOWED_HOSTS'

# Verify DEBUG is False (for production)
# DEBUG should be False, not True

# Generate new SECRET_KEY if using default
python3 -c 'from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())'
# Copy output to .env file
```

---

## 📊 Monitoring Commands

### Check Application Performance
```bash
# View resource usage
docker stats --no-stream random-django-app-web-1

# Check disk usage
df -h

# Check memory usage
free -h

# Check running processes
docker-compose top
```

### Database Status (SQLite)
```bash
# Check database file size
docker-compose exec web ls -lh db.sqlite3

# Access SQLite shell (if needed)
docker-compose exec web python manage.py dbshell
```

---

## 🚨 Emergency Commands

### Application Not Responding
```bash
# Hard restart
docker-compose down
docker-compose up -d web
sleep 10
docker-compose logs web
```

### High CPU/Memory Usage
```bash
# Restart container
docker-compose restart web

# Or restart with resource limits
docker-compose down
# Edit docker-compose.yml to add:
# deploy:
#   resources:
#     limits:
#       cpus: '0.50'
#       memory: 512M
docker-compose up -d web
```

### Container Won't Start
```bash
# Check logs
docker-compose logs web

# Check for port conflicts
sudo lsof -i :9000

# Remove and recreate
docker-compose down
docker-compose up -d web --force-recreate
```

---

## 📅 Regular Maintenance

### Daily
```bash
# Check logs for errors
docker-compose logs --since 24h web | grep -i error
```

### Weekly
```bash
# Backup database
docker-compose exec web cp db.sqlite3 db.sqlite3.backup_$(date +%Y%m%d)

# Check disk space
df -h
```

### Monthly
```bash
# Clean up old Docker images
docker image prune -a -f

# Update application
cd random-django-app
git pull
docker-compose up -d --build web
docker-compose exec web python manage.py migrate
```

---

## 💡 Quick Tips

### Fastest Deployment
```bash
./deploy-sqlite.sh
```

### Safest Deployment (with checks)
```bash
docker-compose ps && \
git pull && \
docker-compose down && \
docker-compose up -d web && \
sleep 15 && \
docker-compose exec web python manage.py migrate && \
docker-compose ps
```

### Deployment with Logs
```bash
./deploy-sqlite.sh && docker-compose logs -f web
```

---

## 📞 Need Help?

If you encounter issues:

1. **Check logs:** `docker-compose logs -f web`
2. **Check container status:** `docker-compose ps`
3. **Check EC2 Security Group:** Port 9000 should be open
4. **Restart application:** `docker-compose restart web`
5. **Full rebuild:** `./deploy-sqlite.sh`

---

## 🔗 Related Documentation

- [README.md](README.md) - Complete project documentation
- [QUICKSTART.md](QUICKSTART.md) - Quick reference guide
- [EC2_DEPLOYMENT_GUIDE.md](EC2_DEPLOYMENT_GUIDE.md) - Detailed EC2 setup
- [DEPLOYMENT_CHECKLIST.md](DEPLOYMENT_CHECKLIST.md) - Step-by-step checklist

---

**Author:** Kunal Rohilla  
**Email:** kunalr.tech@gmail.com  
**Last Updated:** 2025-10-24  
**Application:** Django Task Manager  
**Deployment:** AWS EC2 (13.233.122.241:9000)
