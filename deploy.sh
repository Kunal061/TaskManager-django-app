#!/bin/bash

# Django Task Manager Deployment Script for EC2

echo "🚀 Starting Django Task Manager deployment..."

# Update system packages
echo "📦 Updating system packages..."
sudo yum update -y

# Install Docker
echo "🐳 Installing Docker..."
sudo yum install docker -y
sudo service docker start
sudo usermod -a -G docker ec2-user

# Install Docker Compose
echo "📦 Installing Docker Compose..."
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Install Git if not present
echo "📥 Installing Git..."
sudo yum install git -y

echo "✅ Dependencies installed successfully!"
echo ""
echo "📝 Next steps:"
echo "1. Log out and log back in for Docker group changes to take effect"
echo "2. Clone your repository: git clone <your-repo-url>"
echo "3. Navigate to the project: cd random-django-app"
echo "4. Update .env file with production settings"
echo "5. Build and run: docker-compose up -d --build"
echo "6. Run migrations: docker-compose exec web python manage.py migrate"
echo "7. Create superuser: docker-compose exec web python manage.py createsuperuser"
echo "8. Configure Security Group to allow port 9000"
echo ""
echo "🎉 Setup complete! Access your app at http://<EC2-PUBLIC-IP>:9000"
