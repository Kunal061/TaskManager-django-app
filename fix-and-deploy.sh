#!/bin/bash

# Fix and Deploy Script for EC2
# This script clears Docker cache and rebuilds everything

set -e

echo "🔧 Django Task Manager - Fix and Deploy"
echo "========================================"
echo ""

# Stop and remove all containers
echo "🛑 Stopping existing containers..."
docker-compose down -v 2>/dev/null || true

# Clean Docker cache
echo "🧹 Cleaning Docker cache..."
docker system prune -af --volumes

# Remove old images
echo "🗑️  Removing old images..."
docker-compose down --rmi all 2>/dev/null || true

# Build with no cache
echo "🏗️  Building from scratch (this may take a few minutes)..."
docker-compose build --no-cache --progress=plain

# Start containers
echo "🚀 Starting containers..."
docker-compose up -d

# Wait for services
echo "⏳ Waiting for services to start..."
sleep 30

# Run migrations
echo "📊 Running migrations..."
docker-compose exec -T web python manage.py migrate

# Collect static files
echo "📦 Collecting static files..."
docker-compose exec -T web python manage.py collectstatic --noinput

# Show status
echo ""
echo "✅ Deployment complete!"
echo ""
docker-compose ps
echo ""
echo "🌐 Access your app at: http://13.233.122.241:9000"
echo ""
