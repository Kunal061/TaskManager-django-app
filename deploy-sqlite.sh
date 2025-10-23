#!/bin/bash

echo "🚀 Django Task Manager - SQLite Deployment"
echo "==========================================="
echo ""

# Stop containers
echo "1️⃣ Stopping containers..."
docker-compose down

# Start only web container (no database needed for SQLite)
echo "2️⃣ Starting web container..."
docker-compose up -d web

# Wait for container to start
echo "3️⃣ Waiting for container to start..."
sleep 10

# Check status
echo "4️⃣ Container status:"
docker-compose ps

# Run migrations
echo ""
echo "5️⃣ Running migrations..."
docker-compose exec web python manage.py migrate

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ SUCCESS! Migrations completed!"
    echo ""
    
    # Collect static files
    echo "6️⃣ Collecting static files..."
    docker-compose exec web python manage.py collectstatic --noinput
    
    echo ""
    echo "7️⃣ Create superuser:"
    docker-compose exec web python manage.py createsuperuser
    
    echo ""
    echo "🎉 DEPLOYMENT COMPLETE!"
    echo ""
    echo "📊 Application Details:"
    echo "   • Database: SQLite (file-based, no PostgreSQL needed)"
    echo "   • URL: http://13.233.122.241:9000"
    echo "   • Admin: http://13.233.122.241:9000/admin"
    echo ""
    echo "🔍 Useful Commands:"
    echo "   • View logs: docker-compose logs -f web"
    echo "   • Restart: docker-compose restart web"
    echo "   • Stop: docker-compose down"
    echo ""
else
    echo ""
    echo "❌ Migration failed. Showing logs..."
    docker-compose logs web | tail -30
fi
