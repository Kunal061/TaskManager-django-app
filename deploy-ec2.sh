#!/bin/bash

# Quick Deployment Script for EC2: 13.233.122.241
# Port: 9000
# Author: Kunal Rohilla

set -e

echo "🚀 Django Task Manager - EC2 Quick Deploy"
echo "=========================================="
echo "EC2 IP: 13.233.122.241"
echo "Port: 9000"
echo ""

# Check if running on EC2
if [ ! -f "/etc/system-release" ] && [ ! -f "/etc/lsb-release" ]; then
    echo "⚠️  Warning: This doesn't appear to be an EC2 instance"
    echo "Continue anyway? (y/n)"
    read -r response
    if [ "$response" != "y" ]; then
        exit 1
    fi
fi

# Check Docker installation
if ! command -v docker &> /dev/null; then
    echo "❌ Docker not found!"
    echo "Run the following commands first:"
    echo "  sudo yum install docker -y"
    echo "  sudo service docker start"
    echo "  sudo usermod -a -G docker \$USER"
    echo "Then log out and back in."
    exit 1
fi

# Check Docker Compose installation
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose not found!"
    echo "Run: sudo curl -L \"https://github.com/docker/compose/releases/latest/download/docker-compose-\$(uname -s)-\$(uname -m)\" -o /usr/local/bin/docker-compose"
    echo "Then: sudo chmod +x /usr/local/bin/docker-compose"
    exit 1
fi

echo "✅ Docker found: $(docker --version)"
echo "✅ Docker Compose found: $(docker-compose --version)"
echo ""

# Check if .env exists
if [ ! -f ".env" ]; then
    echo "⚠️  .env file not found. Creating from .env.example..."
    if [ -f ".env.example" ]; then
        cp .env.example .env
        echo "📝 .env file created. You MUST edit it before proceeding!"
        echo ""
        echo "Required changes:"
        echo "1. Generate SECRET_KEY:"
        echo "   python3 -c 'from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())'"
        echo ""
        echo "2. Set DEBUG=False"
        echo "3. Verify ALLOWED_HOSTS=13.233.122.241,localhost,127.0.0.1"
        echo "4. Change DB_PASSWORD to a strong password"
        echo ""
        echo "Edit .env now? (y/n)"
        read -r edit_response
        if [ "$edit_response" = "y" ]; then
            nano .env
        else
            echo "⚠️  Please edit .env manually before running this script again."
            exit 1
        fi
    else
        echo "❌ .env.example not found!"
        exit 1
    fi
fi

echo "🔍 Checking .env configuration..."

# Check if .env has been properly configured
if grep -q "your-super-secret-key-change-this-in-production" .env; then
    echo "❌ ERROR: SECRET_KEY not changed in .env!"
    echo "Generate one with:"
    echo "  python3 -c 'from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())'"
    exit 1
fi

if grep -q "DEBUG=True" .env; then
    echo "⚠️  WARNING: DEBUG is set to True. This should be False for production!"
    echo "Continue anyway? (y/n)"
    read -r debug_response
    if [ "$debug_response" != "y" ]; then
        exit 1
    fi
fi

if ! grep -q "13.233.122.241" .env; then
    echo "⚠️  WARNING: EC2 IP (13.233.122.241) not found in ALLOWED_HOSTS!"
    echo "Continue anyway? (y/n)"
    read -r ip_response
    if [ "$ip_response" != "y" ]; then
        exit 1
    fi
fi

echo "✅ .env configuration looks good!"
echo ""

# Stop existing containers if any
if [ "$(docker-compose ps -q)" ]; then
    echo "🛑 Stopping existing containers..."
    docker-compose down
fi

# Build and start
echo "🏗️  Building Docker images..."
docker-compose build

echo ""
echo "🚀 Starting containers..."
docker-compose up -d

# Wait for services to be ready
echo ""
echo "⏳ Waiting for services to start (30 seconds)..."
sleep 30

# Check if containers are running
echo ""
echo "🔍 Checking container status..."
docker-compose ps

if ! docker-compose ps | grep -q "Up"; then
    echo "❌ Containers failed to start!"
    echo "Check logs with: docker-compose logs"
    exit 1
fi

echo ""
echo "✅ Containers are running!"

# Run migrations
echo ""
echo "📊 Running database migrations..."
docker-compose exec -T web python manage.py migrate

# Collect static files
echo ""
echo "📦 Collecting static files..."
docker-compose exec -T web python manage.py collectstatic --noinput

# Check if superuser exists
echo ""
echo "👤 Checking for superuser..."
echo "Do you want to create a superuser now? (y/n)"
read -r superuser_response
if [ "$superuser_response" = "y" ]; then
    docker-compose exec web python manage.py createsuperuser
fi

echo ""
echo "═══════════════════════════════════════════════════"
echo "🎉 DEPLOYMENT SUCCESSFUL!"
echo "═══════════════════════════════════════════════════"
echo ""
echo "📊 Application Details:"
echo "  • EC2 IP: 13.233.122.241"
echo "  • Port: 9000"
echo "  • Main URL: http://13.233.122.241:9000"
echo "  • Admin URL: http://13.233.122.241:9000/admin"
echo ""
echo "🔍 Verify deployment:"
echo "  • Check logs: docker-compose logs -f"
echo "  • Check status: docker-compose ps"
echo "  • Test locally: curl http://localhost:9000"
echo ""
echo "⚠️  Security Reminders:"
echo "  • Ensure EC2 Security Group allows port 9000"
echo "  • DEBUG should be False in production"
echo "  • Use strong passwords"
echo "  • Keep .env file secure (not in Git)"
echo ""
echo "📚 Documentation:"
echo "  • Quick commands: QUICKSTART.md"
echo "  • Full guide: DEPLOYMENT_CHECKLIST.md"
echo "  • Troubleshooting: EC2_DEPLOYMENT_GUIDE.md"
echo ""
echo "═══════════════════════════════════════════════════"

# Show final container status
echo ""
echo "Container Status:"
docker-compose ps

echo ""
echo "🌐 Access your application now at:"
echo "   http://13.233.122.241:9000"
echo ""
