# Django Task Manager - Testing Guide

## Running Tests Locally

### Using Docker

```bash
# Run all tests
docker-compose exec web python manage.py test

# Run specific app tests
docker-compose exec web python manage.py test tasks

# Run with verbose output
docker-compose exec web python manage.py test --verbosity=2

# Check code coverage
docker-compose exec web coverage run --source='.' manage.py test
docker-compose exec web coverage report
```

### Manual Testing Checklist

#### 1. Application Access
- [ ] Homepage loads at http://localhost:9000 or http://<EC2-IP>:9000
- [ ] Admin panel accessible at /admin/
- [ ] No console errors in browser

#### 2. Task Management
- [ ] Create a new task
- [ ] Edit existing task
- [ ] Delete task (with confirmation)
- [ ] View task list
- [ ] Filter by status
- [ ] Filter by priority

#### 3. Database
- [ ] Tasks persist after container restart
- [ ] Data properly saved in PostgreSQL
- [ ] Migrations run successfully

#### 4. Docker Health
```bash
# All containers running
docker-compose ps

# No error logs
docker-compose logs

# Containers can restart
docker-compose restart
docker-compose ps
```

#### 5. Production Readiness
- [ ] DEBUG=False in .env
- [ ] SECRET_KEY changed from default
- [ ] ALLOWED_HOSTS configured
- [ ] Static files served correctly
- [ ] Database credentials secured

## Performance Testing

### Load Testing with Apache Bench
```bash
# Install Apache Bench
sudo yum install httpd-tools -y  # Amazon Linux
# or
sudo apt install apache2-utils -y  # Ubuntu

# Test homepage
ab -n 100 -c 10 http://localhost:9000/

# Test with authentication
ab -n 100 -c 10 -C "sessionid=YOUR_SESSION_ID" http://localhost:9000/
```

### Expected Performance
- Response time: < 200ms for most pages
- Concurrent users: 50+ (with default settings)
- Database queries: Optimized with select_related/prefetch_related

## Security Testing

### Basic Security Checks
```bash
# Check for common vulnerabilities
docker-compose exec web python manage.py check --deploy

# Verify HTTPS redirect (if SSL configured)
curl -I http://<EC2-IP>:9000

# Test CSRF protection
# Should fail without CSRF token
curl -X POST http://localhost:9000/task/new/
```

## Monitoring

### Container Resource Usage
```bash
# Monitor in real-time
docker stats

# Check disk usage
docker system df
```

### Application Logs
```bash
# Follow all logs
docker-compose logs -f

# Web container only
docker-compose logs -f web

# Last 100 lines
docker-compose logs --tail=100 web
```

## Common Test Scenarios

### Scenario 1: New Deployment
1. Clone repository
2. Configure .env
3. Run docker-compose up -d --build
4. Run migrations
5. Create superuser
6. Access app
7. Create test tasks

### Scenario 2: Update Deployment
1. Pull latest changes
2. docker-compose down
3. docker-compose up -d --build
4. Run new migrations
5. Verify no data loss

### Scenario 3: Database Backup/Restore
1. Create backup
2. Stop containers
3. Remove volumes
4. Start containers
5. Restore backup
6. Verify data

## Debugging Tips

### Container Won't Start
```bash
docker-compose logs web
docker-compose ps
docker inspect <container_id>
```

### Database Connection Issues
```bash
# Check database is ready
docker-compose exec db pg_isready

# Test connection
docker-compose exec web python manage.py dbshell
```

### Static Files Not Loading
```bash
docker-compose exec web python manage.py collectstatic --noinput
docker-compose restart web
```

### Memory Issues
```bash
# Increase Docker memory limit
# Docker Desktop → Settings → Resources → Memory

# Or modify docker-compose.yml
services:
  web:
    mem_limit: 512m
```

## Continuous Integration

### GitHub Actions Example
```yaml
name: Django CI

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Build and test
        run: |
          docker-compose up -d --build
          docker-compose exec -T web python manage.py test
```

## Health Endpoints

Add these to check application health:

```python
# tasks/views.py
from django.http import JsonResponse

def health_check(request):
    return JsonResponse({'status': 'healthy'})

# tasks/urls.py
urlpatterns = [
    path('health/', health_check, name='health'),
]
```

Test:
```bash
curl http://localhost:9000/health/
```

## Automated Testing Script

```bash
#!/bin/bash
# test.sh

set -e

echo "🧪 Running automated tests..."

# Build containers
docker-compose up -d --build

# Wait for services
sleep 10

# Run Django tests
docker-compose exec -T web python manage.py test

# Check migrations
docker-compose exec -T web python manage.py makemigrations --check --dry-run

# Security checks
docker-compose exec -T web python manage.py check --deploy

# Cleanup
docker-compose down

echo "✅ All tests passed!"
```

Make executable:
```bash
chmod +x test.sh
./test.sh
```
