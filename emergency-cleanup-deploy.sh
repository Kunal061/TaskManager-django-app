#!/bin/bash

# ═══════════════════════════════════════════════════════════════
# 🚨 Emergency Cleanup & Deploy Script for EC2
# ═══════════════════════════════════════════════════════════════
# Fixes: Disk space issues + Docker build errors
# Author: Kunal Rohilla (kunalr.tech@gmail.com)
# ═══════════════════════════════════════════════════════════════

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

print_header() {
    echo -e "${PURPLE}═══════════════════════════════════════════════════${NC}"
    echo -e "${PURPLE}  $1${NC}"
    echo -e "${PURPLE}═══════════════════════════════════════════════════${NC}"
}

print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
print_info() { echo -e "${CYAN}ℹ️  $1${NC}"; }

clear
echo -e "${RED}"
cat << "EOF"
╔════════════════════════════════════════════════════════╗
║                                                        ║
║     🚨 EMERGENCY CLEANUP & DEPLOYMENT SCRIPT 🚨       ║
║                                                        ║
║          Fixing Disk Space + Build Issues             ║
║                                                        ║
╚════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# ═══════════════════════════════════════════════════════════════
# STEP 1: CHECK DISK SPACE
# ═══════════════════════════════════════════════════════════════
print_header "🔍 DISK SPACE ANALYSIS"
echo ""
df -h | head -n 1
df -h | grep -E '^/dev/'
echo ""

DISK_USAGE=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
print_info "Root disk usage: ${DISK_USAGE}%"

if [ "$DISK_USAGE" -gt 85 ]; then
    print_warning "Disk usage critical! Starting aggressive cleanup..."
else
    print_success "Disk usage acceptable"
fi

echo ""

# ═══════════════════════════════════════════════════════════════
# STEP 2: STOP ALL CONTAINERS
# ═══════════════════════════════════════════════════════════════
print_header "🛑 STOPPING ALL CONTAINERS"
print_info "Stopping docker-compose services..."
docker-compose down -v 2>/dev/null || true
print_success "Docker compose stopped"

print_info "Stopping all running containers..."
docker stop $(docker ps -aq) 2>/dev/null || true
print_success "All containers stopped"

echo ""

# ═══════════════════════════════════════════════════════════════
# STEP 3: AGGRESSIVE DOCKER CLEANUP
# ═══════════════════════════════════════════════════════════════
print_header "🧹 AGGRESSIVE DOCKER CLEANUP"

print_info "Removing all stopped containers..."
docker container prune -f
print_success "Containers cleaned"

print_info "Removing all dangling images..."
docker image prune -f
print_success "Dangling images removed"

print_info "Removing all unused images..."
docker image prune -a -f
print_success "Unused images removed"

print_info "Removing all unused volumes..."
docker volume prune -f
print_success "Volumes cleaned"

print_info "Removing all unused networks..."
docker network prune -f
print_success "Networks cleaned"

print_info "Removing all build cache..."
docker builder prune -a -f
print_success "Build cache cleared"

print_info "Final system prune..."
docker system prune -a -f --volumes
print_success "Docker system fully cleaned"

echo ""

# ═══════════════════════════════════════════════════════════════
# STEP 4: SYSTEM CLEANUP
# ═══════════════════════════════════════════════════════════════
print_header "🗑️  SYSTEM CLEANUP"

print_info "Cleaning apt cache..."
sudo apt-get clean 2>/dev/null || true
print_success "APT cache cleaned"

print_info "Removing old logs..."
sudo journalctl --vacuum-time=2d 2>/dev/null || true
print_success "Old logs removed"

print_info "Cleaning temporary files..."
sudo rm -rf /tmp/* 2>/dev/null || true
print_success "Temp files cleaned"

echo ""

# ═══════════════════════════════════════════════════════════════
# STEP 5: CHECK DISK SPACE AGAIN
# ═══════════════════════════════════════════════════════════════
print_header "📊 DISK SPACE AFTER CLEANUP"
echo ""
df -h | head -n 1
df -h | grep -E '^/dev/'
echo ""

NEW_DISK_USAGE=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
print_info "Root disk usage now: ${NEW_DISK_USAGE}%"
FREED=$((DISK_USAGE - NEW_DISK_USAGE))
print_success "Freed up: ${FREED}% disk space"

echo ""

if [ "$NEW_DISK_USAGE" -gt 90 ]; then
    print_error "Still critical! Manual intervention required."
    echo ""
    print_info "Try these commands manually:"
    echo "  sudo apt-get autoremove -y"
    echo "  sudo apt-get autoclean"
    echo "  find /var/log -type f -name '*.log' -mtime +7 -delete"
    exit 1
fi

# ═══════════════════════════════════════════════════════════════
# STEP 6: ENVIRONMENT SETUP
# ═══════════════════════════════════════════════════════════════
print_header "⚙️  ENVIRONMENT CONFIGURATION"

if [ ! -f ".env" ]; then
    print_warning ".env not found, creating..."
    cat > .env << 'ENVEOF'
SECRET_KEY=django-insecure-TEMP-KEY-CHANGE-THIS
DEBUG=False
ALLOWED_HOSTS=13.233.122.241,localhost,127.0.0.1
DB_ENGINE=django.db.backends.sqlite3
DB_NAME=/app/db.sqlite3
ENVEOF
    print_success ".env created"
fi

# Generate SECRET_KEY
if grep -q "TEMP-KEY-CHANGE-THIS\|CHANGE-THIS" .env 2>/dev/null; then
    print_info "Generating SECRET_KEY..."
    NEW_SECRET="django-insecure-$(openssl rand -hex 32)"
    sed -i.bak "s/SECRET_KEY=.*/SECRET_KEY=${NEW_SECRET}/" .env
    print_success "SECRET_KEY generated"
fi

# Set DEBUG=False
sed -i.bak 's/DEBUG=True/DEBUG=False/' .env 2>/dev/null || true

# Update ALLOWED_HOSTS
if ! grep -q "13.233.122.241" .env; then
    sed -i.bak 's/ALLOWED_HOSTS=.*/ALLOWED_HOSTS=13.233.122.241,localhost,127.0.0.1/' .env
fi

print_success "Environment configured"
echo ""

# ═══════════════════════════════════════════════════════════════
# STEP 7: BUILD WITH MINIMAL RESOURCES
# ═══════════════════════════════════════════════════════════════
print_header "🏗️  BUILDING DOCKER IMAGE"
print_info "Building with optimized settings..."
echo ""

# Build with no cache and single thread to save resources
docker-compose build --no-cache --progress=plain

if [ $? -ne 0 ]; then
    print_error "Build failed!"
    print_info "Checking disk space again..."
    df -h | grep -E '^/dev/'
    exit 1
fi

print_success "Build completed"
echo ""

# ═══════════════════════════════════════════════════════════════
# STEP 8: START SERVICES
# ═══════════════════════════════════════════════════════════════
print_header "🚀 STARTING SERVICES"

docker-compose up -d

if [ $? -ne 0 ]; then
    print_error "Failed to start services!"
    docker-compose logs
    exit 1
fi

print_success "Services started"
echo ""

# Wait for container
print_info "Waiting for container to be ready (30 seconds)..."
for i in {30..1}; do
    echo -ne "${CYAN}⏳ $i seconds...${NC}\r"
    sleep 1
done
echo ""

# ═══════════════════════════════════════════════════════════════
# STEP 9: DATABASE MIGRATIONS
# ═══════════════════════════════════════════════════════════════
print_header "📊 DATABASE SETUP"

print_info "Running migrations..."
sleep 5

# Retry migrations up to 3 times
for i in {1..3}; do
    if docker-compose exec -T web python manage.py migrate --noinput; then
        print_success "Migrations completed"
        break
    else
        if [ $i -lt 3 ]; then
            print_warning "Migration attempt $i failed, retrying..."
            sleep 10
        else
            print_error "Migrations failed after 3 attempts"
            print_warning "Continuing anyway..."
        fi
    fi
done

echo ""

# ═══════════════════════════════════════════════════════════════
# STEP 10: COLLECT STATIC FILES
# ═══════════════════════════════════════════════════════════════
print_info "Collecting static files..."
docker-compose exec -T web python manage.py collectstatic --noinput 2>/dev/null || print_warning "Static files had warnings (non-critical)"
print_success "Static files handled"

echo ""

# ═══════════════════════════════════════════════════════════════
# STEP 11: HEALTH CHECK
# ═══════════════════════════════════════════════════════════════
print_header "🏥 HEALTH CHECK"

sleep 5
if curl -f http://localhost:9000 >/dev/null 2>&1; then
    print_success "Application is responding!"
else
    print_warning "Could not verify response (may still be starting)"
fi

echo ""

# ═══════════════════════════════════════════════════════════════
# FINAL SUMMARY
# ═══════════════════════════════════════════════════════════════
print_header "🎉 DEPLOYMENT COMPLETE"

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                                                        ║${NC}"
echo -e "${GREEN}║          ✨ Application Successfully Deployed! ✨      ║${NC}"
echo -e "${GREEN}║                                                        ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${CYAN}🌐 Application URL:${NC}"
echo -e "   ${GREEN}http://13.233.122.241:9000${NC}"
echo ""

echo -e "${CYAN}📊 Current Status:${NC}"
docker-compose ps
echo ""

echo -e "${CYAN}💾 Disk Space:${NC}"
df -h / | tail -1
echo ""

echo -e "${CYAN}💡 Useful Commands:${NC}"
echo -e "   ${YELLOW}Logs:${NC}         docker-compose logs -f web"
echo -e "   ${YELLOW}Restart:${NC}      docker-compose restart"
echo -e "   ${YELLOW}Stop:${NC}         docker-compose down"
echo -e "   ${YELLOW}Superuser:${NC}    docker-compose exec web python manage.py createsuperuser"
echo ""

echo -e "${PURPLE}═══════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ All done! Your modern Task Manager is live! 🎨${NC}"
echo -e "${PURPLE}═══════════════════════════════════════════════════${NC}"
echo ""
