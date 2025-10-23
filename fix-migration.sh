#!/bin/bash

echo "🔧 Fixing Migration Issue..."
echo "================================"

# Step 1: Stop all containers
echo "1️⃣ Stopping containers..."
docker-compose down

# Step 2: Remove the postgres data volume specifically
echo "2️⃣ Removing old database volume..."
docker volume rm random-django-app_postgres_data 2>/dev/null || echo "   Volume already removed or doesn't exist"

# Step 3: Start only the database first
echo "3️⃣ Starting database container..."
docker-compose up -d db

# Step 4: Wait for database to fully initialize
echo "4️⃣ Waiting for database to initialize (30 seconds)..."
sleep 30

# Step 5: Check database is ready
echo "5️⃣ Checking database readiness..."
docker-compose exec db pg_isready -U taskmanager_user -d taskmanager_db
if [ $? -eq 0 ]; then
    echo "   ✅ Database is ready!"
else
    echo "   ⚠️  Database not ready yet, waiting 10 more seconds..."
    sleep 10
fi

# Step 6: Start web container
echo "6️⃣ Starting web container..."
docker-compose up -d web

# Wait a bit
sleep 5

# Step 7: Run migrations
echo "7️⃣ Running migrations..."
docker-compose exec web python manage.py migrate

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ SUCCESS! Migrations completed!"
    echo ""
    echo "📋 Next steps:"
    echo "   1. Create superuser: docker-compose exec web python manage.py createsuperuser"
    echo "   2. Collect static: docker-compose exec web python manage.py collectstatic --noinput"
    echo "   3. Access app: http://13.233.122.241:9000"
else
    echo ""
    echo "❌ Migration failed. Showing logs..."
    docker-compose logs web | tail -30
fi
