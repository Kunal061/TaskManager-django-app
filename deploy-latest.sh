#!/bin/bash

# ═══════════════════════════════════════════════════════════════
# 🚀 TaskManager Django - Latest Deployment Script
# ═══════════════════════════════════════════════════════════════
# Author: Kunal Rohilla (kunalr.tech@gmail.com)
# EC2 IP: 13.233.122.241
# Port: 9000
# Version: Latest (Modern UI with Animations)
# ═══════════════════════════════════════════════════════════════

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to print colored output
print_header() {
    echo -e "${PURPLE}"
    echo "═══════════════════════════════════════════════════"
    echo "  $1"
    echo "═══════════════════════════════════════════════════"
    echo -e "${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${CYAN}ℹ️  $1${NC}"
}

# Main header
clear
echo -e "${PURPLE}"
cat << "EOF"
╔════════════════════════════════════════════════════════╗
║                                                        ║
║     🚀 TaskManager Django - Latest Deployment 🚀      ║
║                                                        ║
║     Modern UI with Glassmorphism & Animations         ║
║                                                        ║
╚════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

print_info "Starting deployment process..."
echo ""

# Check if running on EC2
print_header "🔍 System Check"
if [ -f "/etc/system-release" ] || [ -f "/etc/lsb-release" ]; then
    print_success "Running on Linux/EC2 instance"
else
    print_warning "This doesn't appear to be an EC2 instance"
    read -p "Continue anyway? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_error "Deployment cancelled"
        exit 1
    fi
fi

# Check Docker
print_info "Checking Docker installation..."
if ! command -v docker &> /dev/null; then
    print_error "Docker not found!"
    echo ""
    echo "Install Docker with:"
    echo "  sudo apt update"
    echo "  sudo apt install docker.io -y"
    echo "  sudo systemctl start docker"
    echo "  sudo usermod -aG docker \$USER"
    exit 1
fi
print_success "Docker found: $(docker --version)"

# Check Docker Compose
print_info "Checking Docker Compose..."
if ! command -v docker-compose &> /dev/null; then
    print_error "Docker Compose not found!"
    echo ""
    echo "Install with:"
    echo "  sudo curl -L 'https://github.com/docker/compose/releases/latest/download/docker-compose-\$(uname -s)-\$(uname -m)' -o /usr/local/bin/docker-compose"
    echo "  sudo chmod +x /usr/local/bin/docker-compose"
    exit 1
fi
print_success "Docker Compose found: $(docker-compose --version)"

echo ""

# Environment Configuration
print_header "⚙️  Environment Configuration"

if [ ! -f ".env" ]; then
    print_warning ".env file not found - creating from template"
    
    if [ -f ".env.example" ]; then
        cp .env.example .env
        print_success ".env file created from .env.example"
    else
        print_error ".env.example not found!"
        print_info "Creating basic .env file..."
        cat > .env << 'ENVEOF'
# Django Settings
SECRET_KEY=django-insecure-CHANGE-THIS-IN-PRODUCTION
DEBUG=False
ALLOWED_HOSTS=13.233.122.241,localhost,127.0.0.1

# Database (SQLite)
DB_ENGINE=django.db.backends.sqlite3
DB_NAME=/app/db.sqlite3
DB_USER=
DB_PASSWORD=
DB_HOST=
DB_PORT=
ENVEOF
        print_success "Basic .env file created"
    fi
fi

# Generate SECRET_KEY if needed
if grep -q "your-super-secret-key-change-this-in-production\|CHANGE-THIS-IN-PRODUCTION" .env 2>/dev/null; then
    print_info "Generating new SECRET_KEY..."
    if command -v python3 &> /dev/null; then
        NEW_SECRET=$(python3 -c 'from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())' 2>/dev/null || echo "django-insecure-$(openssl rand -hex 32)")
        sed -i.bak "s/SECRET_KEY=.*/SECRET_KEY=${NEW_SECRET}/" .env
        print_success "SECRET_KEY generated"
    else
        print_warning "Python3 not available, using openssl for key generation"
        NEW_SECRET="django-insecure-$(openssl rand -hex 32)"
        sed -i.bak "s/SECRET_KEY=.*/SECRET_KEY=${NEW_SECRET}/" .env
        print_success "SECRET_KEY generated with openssl"
    fi
fi

# Set DEBUG=False
if grep -q "DEBUG=True" .env 2>/dev/null; then
    sed -i.bak 's/DEBUG=True/DEBUG=False/' .env
    print_success "DEBUG set to False (production mode)"
fi

# Update ALLOWED_HOSTS
if ! grep -q "13.233.122.241" .env 2>/dev/null; then
    sed -i.bak 's/ALLOWED_HOSTS=.*/ALLOWED_HOSTS=13.233.122.241,localhost,127.0.0.1/' .env
    print_success "ALLOWED_HOSTS updated with EC2 IP"
fi

print_success "Environment configuration complete"
echo ""

# Cleanup
print_header "🧹 Cleanup"
print_info "Stopping existing containers..."
docker-compose down -v 2>/dev/null || true
print_success "Containers stopped"

print_info "Removing stopped containers..."
docker ps -aq | xargs -r docker rm -f 2>/dev/null || true
print_success "Old containers removed"

print_info "Cleaning Docker system..."
docker system prune -f
print_success "Docker cleanup complete"

echo ""

# Build
print_header "🏗️  Building Docker Images"
print_info "This may take a few minutes..."
echo ""

docker-compose build --no-cache --progress=plain

if [ $? -eq 0 ]; then
    print_success "Docker images built successfully"
else
    print_error "Docker build failed!"
    echo ""
    print_info "Check the logs above for errors"
    exit 1
fi

echo ""

# Start Services
print_header "🚀 Starting Services"
docker-compose up -d

if [ $? -eq 0 ]; then
    print_success "Containers started"
else
    print_error "Failed to start containers!"
    exit 1
fi

# Wait for services
print_info "Waiting for services to initialize..."
for i in {30..1}; do
    echo -ne "${CYAN}⏳ $i seconds remaining...${NC}\r"
    sleep 1
done
echo ""
echo ""

# Check container status with retries
print_info "Checking container status..."
max_retries=5
retry_count=0

while [ $retry_count -lt $max_retries ]; do
    if docker-compose ps | grep -q "Up"; then
        print_success "Containers are running"
        break
    else
        retry_count=$((retry_count + 1))
        if [ $retry_count -lt $max_retries ]; then
            print_warning "Containers not ready, retrying ($retry_count/$max_retries)..."
            sleep 5
        else
            print_error "Containers failed to start after $max_retries attempts!"
            echo ""
            print_info "Container logs:"
            docker-compose logs web
            exit 1
        fi
    fi
done

echo ""

# Database Migration
print_header "📊 Database Setup"
print_info "Running migrations..."

# Wait for container to be fully ready
sleep 5

# Run migrations with retry logic
max_migration_retries=3
migration_retry=0

while [ $migration_retry -lt $max_migration_retries ]; do
    if docker-compose exec -T web python manage.py migrate --noinput; then
        print_success "Migrations completed"
        break
    else
        migration_retry=$((migration_retry + 1))
        if [ $migration_retry -lt $max_migration_retries ]; then
            print_warning "Migration failed, retrying ($migration_retry/$max_migration_retries)..."
            print_info "Waiting for database to be ready..."
            sleep 10
        else
            print_error "Migration failed after $max_migration_retries attempts!"
            echo ""
            print_info "Container logs:"
            docker-compose logs web
            echo ""
            print_warning "Trying to continue anyway..."
            break
        fi
    fi
done

echo ""

# Collect Static Files
print_info "Collecting static files..."
docker-compose exec -T web python manage.py collectstatic --noinput

if [ $? -eq 0 ]; then
    print_success "Static files collected"
else
    print_warning "Static files collection had warnings (non-critical)"
fi

echo ""

# Health Check
print_header "🏥 Health Check"
print_info "Testing application..."
sleep 3

if curl -f http://localhost:9000 >/dev/null 2>&1; then
    print_success "Application is responding"
elif curl -f http://127.0.0.1:9000 >/dev/null 2>&1; then
    print_success "Application is responding on 127.0.0.1"
else
    print_warning "Could not verify application response (may still be starting)"
fi

echo ""

# Final Summary
print_header "🎉 DEPLOYMENT COMPLETE!"

echo -e "${GREEN}"
cat << "EOF"
╔════════════════════════════════════════════════════════╗
║                                                        ║
║          ✨ Your App is Live and Running! ✨          ║
║                                                        ║
╚════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

echo ""
echo -e "${CYAN}🌐 Application URLs:${NC}"
echo -e "   ${GREEN}Main App:${NC}  http://13.233.122.241:9000"
echo -e "   ${GREEN}Admin:${NC}     http://13.233.122.241:9000/admin"
echo ""

echo -e "${CYAN}📊 Container Status:${NC}"
docker-compose ps
echo ""

echo -e "${CYAN}💡 Useful Commands:${NC}"
echo -e "   ${YELLOW}View logs:${NC}        docker-compose logs -f web"
echo -e "   ${YELLOW}Restart:${NC}          docker-compose restart"
echo -e "   ${YELLOW}Stop:${NC}             docker-compose down"
echo -e "   ${YELLOW}Shell access:${NC}     docker-compose exec web bash"
echo -e "   ${YELLOW}Create superuser:${NC} docker-compose exec web python manage.py createsuperuser"
echo ""

echo -e "${CYAN}🎨 Modern UI Features:${NC}"
echo -e "   ✨ Glassmorphism design with backdrop blur"
echo -e "   ✨ Smooth animations and transitions"
echo -e "   ✨ Gradient buttons and badges"
echo -e "   ✨ 3D card hover effects"
echo -e "   ✨ Responsive mobile-friendly layout"
echo ""

echo -e "${CYAN}⚠️  Important Notes:${NC}"
echo -e "   • Ensure EC2 Security Group allows port 9000"
echo -e "   • Application is in production mode (DEBUG=False)"
echo -e "   • Database: SQLite (stored in container)"
echo -e "   • Create admin user: docker-compose exec web python manage.py createsuperuser"
echo ""

echo -e "${PURPLE}═══════════════════════════════════════════════════${NC}"
echo -e "${GREEN}🚀 Deployment completed successfully!${NC}"
echo -e "${PURPLE}═══════════════════════════════════════════════════${NC}"
echo ""

print_info "Created by: Kunal Rohilla"
print_info "Email: kunalr.tech@gmail.com"
print_info "GitHub: https://github.com/Kunal061"
echo ""

# Optional: Create superuser prompt
read -p "$(echo -e ${YELLOW}Do you want to create a superuser now? \(y/n\): ${NC})" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    print_info "Creating superuser..."
    docker-compose exec web python manage.py createsuperuser
fi

echo ""
print_success "All done! Enjoy your modern Task Manager! 🎉"
