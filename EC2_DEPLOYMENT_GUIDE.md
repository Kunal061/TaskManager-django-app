# EC2 Deployment Guide for Django Task Manager

## Prerequisites
- AWS EC2 instance (Amazon Linux 2 or Ubuntu)
- Security group configured to allow SSH (port 22) and Custom TCP (port 9000)
- SSH key pair to access the instance

## Step-by-Step Deployment

### 1. Launch EC2 Instance

1. Go to AWS Console → EC2 → Launch Instance
2. Choose **Amazon Linux 2023** or **Ubuntu 22.04 LTS**
3. Select instance type (t2.micro for free tier)
4. Configure Security Group:
   - SSH (22) - Your IP
   - Custom TCP (9000) - 0.0.0.0/0 (or your IP for security)
5. Launch and download the key pair

### 2. Connect to EC2 Instance

```bash
chmod 400 your-key.pem
ssh -i your-key.pem ec2-user@<EC2-PUBLIC-IP>
# For Ubuntu, use: ssh -i your-key.pem ubuntu@<EC2-PUBLIC-IP>
```

### 3. Install Docker and Docker Compose (Amazon Linux 2023)

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

# Log out and log back in
exit
```

**Re-connect to EC2:**
```bash
ssh -i your-key.pem ec2-user@<EC2-PUBLIC-IP>
```

### 4. For Ubuntu (Alternative)

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
sudo apt install docker.io -y
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ubuntu

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Install Git
sudo apt install git -y

# Log out and log back in
exit
```

### 5. Clone and Configure the Application

```bash
# Clone repository
git clone <YOUR-REPOSITORY-URL>
cd random-django-app

# Create production environment file
cp .env.example .env
nano .env
```

**Update .env with production values:**
```env
SECRET_KEY=<generate-new-secret-key>
DEBUG=False
ALLOWED_HOSTS=<EC2-PUBLIC-IP>,localhost,127.0.0.1

DB_ENGINE=django.db.backends.postgresql
DB_NAME=taskmanager_db
DB_USER=taskmanager_user
DB_PASSWORD=<STRONG-PASSWORD>
DB_HOST=db
DB_PORT=5432
```

**Generate a new SECRET_KEY:**
```bash
python3 -c 'from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())'
```

### 6. Build and Run the Application

```bash
# Build and start containers
docker-compose up -d --build

# Wait for containers to be ready (30 seconds)
sleep 30

# Check if containers are running
docker-compose ps

# Run database migrations
docker-compose exec web python manage.py migrate

# Create a superuser for admin access
docker-compose exec web python manage.py createsuperuser

# Collect static files (if needed)
docker-compose exec web python manage.py collectstatic --noinput
```

### 7. Verify Deployment

```bash
# Check logs
docker-compose logs -f web

# Check if app is responding
curl http://localhost:9000
```

### 8. Access the Application

Open your browser and navigate to:
- **Main App:** `http://<EC2-PUBLIC-IP>:9000`
- **Admin Panel:** `http://<EC2-PUBLIC-IP>:9000/admin`

## Useful Commands

### Managing the Application

```bash
# View logs
docker-compose logs -f

# Stop the application
docker-compose down

# Restart the application
docker-compose restart

# Rebuild and restart
docker-compose up -d --build

# Access Django shell
docker-compose exec web python manage.py shell

# Create new migrations
docker-compose exec web python manage.py makemigrations

# Apply migrations
docker-compose exec web python manage.py migrate
```

### Database Management

```bash
# Backup database
docker-compose exec db pg_dump -U taskmanager_user taskmanager_db > backup.sql

# Restore database
cat backup.sql | docker-compose exec -T db psql -U taskmanager_user taskmanager_db

# Access PostgreSQL shell
docker-compose exec db psql -U taskmanager_user -d taskmanager_db
```

## Troubleshooting

### Application not accessible from browser

1. Check Security Group allows port 9000
2. Verify containers are running: `docker-compose ps`
3. Check logs: `docker-compose logs web`

### Database connection errors

1. Ensure database container is healthy: `docker-compose ps`
2. Check database logs: `docker-compose logs db`
3. Verify .env settings match docker-compose.yml

### Permission denied errors

```bash
# Fix Docker permissions
sudo usermod -aG docker $USER
# Log out and log back in
```

### Out of disk space

```bash
# Clean up Docker
docker system prune -a
docker volume prune
```

## Production Best Practices

1. **Use HTTPS:** Set up SSL/TLS with Let's Encrypt and Nginx reverse proxy
2. **Use RDS:** Consider using AWS RDS for PostgreSQL instead of container DB
3. **Enable Backups:** Set up automated database backups
4. **Monitor Resources:** Use CloudWatch or similar for monitoring
5. **Use .env secrets:** Never commit .env to Git
6. **Update Regularly:** Keep Docker images and dependencies updated
7. **Set up CI/CD:** Automate deployments with GitHub Actions or AWS CodeDeploy

## SSL/TLS Setup (Optional)

For production, add Nginx as reverse proxy with SSL:

1. Install Certbot on EC2
2. Get SSL certificate from Let's Encrypt
3. Add Nginx container to docker-compose.yml
4. Configure Nginx to proxy to Django on port 9000
5. Update Security Group to allow HTTPS (443)

## Stopping and Removing

```bash
# Stop and remove all containers
docker-compose down

# Remove all data (including database)
docker-compose down -v
```

## Support

For issues or questions, check:
- Application logs: `docker-compose logs`
- Django documentation: https://docs.djangoproject.com/
- Docker documentation: https://docs.docker.com/

---

**Note:** Replace `<EC2-PUBLIC-IP>` and `<YOUR-REPOSITORY-URL>` with your actual values.
