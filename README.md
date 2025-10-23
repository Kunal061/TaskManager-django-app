# Django Task Manager App

A modern, feature-rich task management web application built with Django and Docker.

## Features

- ✅ Create, Read, Update, Delete (CRUD) tasks
- 📊 Task priority levels (Low, Medium, High)
- ✔️ Task status tracking (Pending, In Progress, Completed)
- 🎨 Modern, responsive UI with Bootstrap 5
- 🐳 Fully containerized with Docker
- 🗄️ PostgreSQL database
- 🚀 Production-ready with Gunicorn

## Quick Start

### Local Development with Docker

1. Clone the repository:
```bash
git clone <your-repo-url>
cd random-django-app
```

2. Build and run with Docker Compose:
```bash
docker-compose up --build
```

3. Run migrations (in another terminal):
```bash
docker-compose exec web python manage.py migrate
docker-compose exec web python manage.py createsuperuser
```

4. Access the app:
- Main app: http://localhost:9000
- Admin panel: http://localhost:9000/admin

### EC2 Deployment

1. SSH into your EC2 instance

2. Install Docker and Docker Compose:
```bash
sudo yum update -y
sudo yum install docker -y
sudo service docker start
sudo usermod -a -G docker ec2-user
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

3. Clone and run:
```bash
git clone <your-repo-url>
cd random-django-app
docker-compose up -d --build
```

4. Run migrations:
```bash
docker-compose exec web python manage.py migrate
docker-compose exec web python manage.py createsuperuser
```

5. Configure EC2 Security Group to allow inbound traffic on port 9000

## Environment Variables

Update `.env` file for production:
- `SECRET_KEY`: Generate a new secret key
- `DEBUG`: Set to False in production
- `ALLOWED_HOSTS`: Add your EC2 public IP or domain

## Tech Stack

- Django 4.2
- PostgreSQL 15
- Gunicorn
- Docker & Docker Compose
- Bootstrap 5
- WhiteNoise (static files)

## License

MIT
