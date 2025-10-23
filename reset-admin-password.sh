#!/bin/bash

# Reset Admin Password Script
# Usage: ./reset-admin-password.sh

echo "🔐 Django Admin Password Reset Utility"
echo "======================================"
echo ""

# Check if container is running
if ! docker-compose ps | grep -q "web.*Up"; then
    echo "❌ Web container is not running!"
    echo "Starting container..."
    docker-compose up -d web
    sleep 5
fi

echo "Current superusers in the system:"
docker-compose exec web python manage.py shell -c "
from django.contrib.auth.models import User
for u in User.objects.filter(is_superuser=True):
    print(f'  - {u.username} ({u.email})')
"

echo ""
echo "Choose an option:"
echo "1) Reset admin password (interactive)"
echo "2) Create new superuser"
echo "3) List all users"
echo "4) Reset password for specific user"
echo ""
read -p "Enter choice [1-4]: " choice

case $choice in
    1)
        echo ""
        echo "Resetting password for 'admin' user..."
        docker-compose exec web python manage.py changepassword admin
        ;;
    2)
        echo ""
        echo "Creating new superuser..."
        docker-compose exec web python manage.py createsuperuser
        ;;
    3)
        echo ""
        echo "All users in the system:"
        docker-compose exec web python manage.py shell -c "
from django.contrib.auth.models import User
for u in User.objects.all():
    superuser = '(SUPERUSER)' if u.is_superuser else ''
    print(f'  - {u.username} {superuser} - {u.email}')
"
        ;;
    4)
        echo ""
        read -p "Enter username: " username
        docker-compose exec web python manage.py changepassword "$username"
        ;;
    *)
        echo "Invalid choice!"
        exit 1
        ;;
esac

echo ""
echo "✅ Done!"
echo ""
echo "You can now login at: http://13.233.122.241:9000/admin/"
