#!/bin/bash

echo "🔥 ULTIMATE DATABASE FIX"
echo "========================="
echo ""

# 1. Stop everything
echo "1️⃣ Stopping all containers..."
docker-compose down
docker stop $(docker ps -aq) 2>/dev/null || true

# 2. Remove ALL project-related volumes
echo "2️⃣ Removing all project volumes..."
docker volume ls | grep random-django-app | awk '{print $2}' | xargs -r docker volume rm
docker volume prune -f

# 3. Remove containers
echo "3️⃣ Removing containers..."
docker-compose rm -f

# 4. Clean docker cache
echo "4️⃣ Cleaning Docker cache..."
docker system prune -f

# 5. Verify volumes are gone
echo "5️⃣ Verifying volumes removed..."
docker volume ls | grep random-django || echo "   ✅ All volumes removed"

# 6. Start ONLY database first
echo "6️⃣ Starting database container..."
docker-compose up -d db

# 7. Wait for database initialization
echo "7️⃣ Waiting for database initialization (45 seconds)..."
for i in {45..1}; do
    echo -ne "   Waiting: $i seconds remaining...\r"
    sleep 1
done
echo ""

# 8. Verify database is running
echo "8️⃣ Verifying database status..."
docker-compose ps db

# 9. Check database logs
echo "9️⃣ Checking database logs..."
docker-compose logs db | grep "database system is ready" && echo "   ✅ Database ready!" || echo "   ⚠️  Database might need more time"

# 10. Test database connection
echo "🔟 Testing database connection..."
docker-compose exec db psql -U taskmanager_user -d taskmanager_db -c "SELECT version();" 2>&1 | grep PostgreSQL && echo "   ✅ Database connection works!" || echo "   ⚠️  Connection test failed"

# 11. Start web container
echo "1️⃣1️⃣ Starting web container..."
docker-compose up -d web

# Wait for web to start
sleep 10

# 12. Show all containers
echo "1️⃣2️⃣ Container status:"
docker-compose ps

# 13. Run migrations
echo ""
echo "1️⃣3️⃣ Running migrations..."
echo "================================="
docker-compose exec web python manage.py migrate

# Check result
if [ $? -eq 0 ]; then
    echo ""
    echo "🎉 SUCCESS! Migration completed!"
    echo ""
    echo "📋 Next commands to run:"
    echo "   docker-compose exec web python manage.py createsuperuser"
    echo "   docker-compose exec web python manage.py collectstatic --noinput"
    echo ""
    echo "🌐 Access your app at: http://13.233.122.241:9000"
else
    echo ""
    echo "❌ Migration still failed. Showing detailed logs..."
    echo ""
    echo "=== WEB CONTAINER LOGS ==="
    docker-compose logs web | tail -50
    echo ""
    echo "=== DATABASE CONTAINER LOGS ==="
    docker-compose logs db | tail -30
    echo ""
    echo "=== ENVIRONMENT CHECK ==="
    docker-compose exec web env | grep DB_
fi
