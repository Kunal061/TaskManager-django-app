#!/bin/bash

# Local development script

echo "🚀 Starting Django Task Manager locally..."

# Build and start containers
echo "🐳 Building and starting Docker containers..."
docker-compose up --build -d

# Wait for database to be ready
echo "⏳ Waiting for database to be ready..."
sleep 5

# Run migrations
echo "📊 Running database migrations..."
docker-compose exec web python manage.py migrate

# Create superuser (optional)
echo ""
echo "👤 Create a superuser for admin access:"
docker-compose exec web python manage.py createsuperuser

echo ""
echo "✅ Application is running!"
echo "🌐 Access the app at: http://localhost:9000"
echo "🔧 Admin panel at: http://localhost:9000/admin"
echo ""
echo "📋 Useful commands:"
echo "  View logs: docker-compose logs -f"
echo "  Stop app: docker-compose down"
echo "  Restart: docker-compose restart"
