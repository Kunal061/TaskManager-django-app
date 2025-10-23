# Quick Start Guide

## 🚀 Quick Deploy to EC2

### One-Command Setup (Amazon Linux)
```bash
curl -o- https://raw.githubusercontent.com/YOUR-USERNAME/random-django-app/main/deploy.sh | bash
```

### Manual Quick Start

1. **Clone the repo:**
   ```bash
   git clone <YOUR-REPO-URL>
   cd random-django-app
   ```

2. **Update environment:**
   ```bash
   cp .env.example .env
   nano .env  # Update SECRET_KEY, DEBUG=False, ALLOWED_HOSTS
   ```

3. **Run:**
   ```bash
   docker-compose up -d --build
   docker-compose exec web python manage.py migrate
   docker-compose exec web python manage.py createsuperuser
   ```

4. **Access:** `http://<EC2-IP>:9000`

## 🐳 Essential Commands

| Action | Command |
|--------|---------|
| Start | `docker-compose up -d` |
| Stop | `docker-compose down` |
| Logs | `docker-compose logs -f` |
| Rebuild | `docker-compose up -d --build` |
| Migrate | `docker-compose exec web python manage.py migrate` |
| Shell | `docker-compose exec web python manage.py shell` |
| Superuser | `docker-compose exec web python manage.py createsuperuser` |

## 🔒 Security Checklist for Production

- [ ] Generate new SECRET_KEY
- [ ] Set DEBUG=False
- [ ] Update ALLOWED_HOSTS with EC2 IP
- [ ] Change DB_PASSWORD
- [ ] Configure EC2 Security Group (port 9000)
- [ ] Enable HTTPS (optional but recommended)
- [ ] Set up database backups

## 📋 EC2 Security Group Settings

| Type | Protocol | Port | Source |
|------|----------|------|--------|
| SSH | TCP | 22 | Your IP |
| Custom TCP | TCP | 9000 | 0.0.0.0/0 |
| HTTPS (optional) | TCP | 443 | 0.0.0.0/0 |

## 🎯 Features

- ✅ Full CRUD operations for tasks
- 📊 Priority levels (Low, Medium, High)
- ✔️ Status tracking (Pending, In Progress, Completed)
- 🎨 Modern responsive UI with Bootstrap 5
- 🔍 Filter tasks by status and priority
- 📅 Due date tracking
- 🐳 Production-ready Docker setup
- 🗄️ PostgreSQL database
- 🚀 Gunicorn WSGI server

## 📁 Project Structure

```
random-django-app/
├── Dockerfile                 # Docker image definition
├── docker-compose.yml         # Multi-container setup
├── requirements.txt           # Python dependencies
├── .env                       # Environment variables
├── manage.py                  # Django management
├── taskmanager/              # Django project
│   ├── settings.py           # Configuration
│   ├── urls.py               # URL routing
│   └── wsgi.py               # WSGI config
├── tasks/                    # Main app
│   ├── models.py             # Task model
│   ├── views.py              # Views
│   ├── forms.py              # Forms
│   ├── urls.py               # App URLs
│   └── admin.py              # Admin config
└── templates/                # HTML templates
    ├── base.html
    └── tasks/
        ├── task_list.html
        ├── task_form.html
        └── task_confirm_delete.html
```

## 🆘 Troubleshooting

**App not accessible?**
- Check Security Group allows port 9000
- Run: `docker-compose ps` to verify containers
- Check logs: `docker-compose logs web`

**Database errors?**
- Verify .env settings
- Check: `docker-compose logs db`

**Permission issues?**
```bash
sudo usermod -aG docker $USER
# Log out and back in
```

## 📚 Learn More

- [Full EC2 Deployment Guide](EC2_DEPLOYMENT_GUIDE.md)
- [Django Documentation](https://docs.djangoproject.com/)
- [Docker Documentation](https://docs.docker.com/)

---

**Need help?** Check the logs: `docker-compose logs -f`
