# 🔐 Database Access Guide - Fetching User Credentials

This guide shows you how to access and retrieve user ID and password information from your Django SQLite database.

---

## 📍 Database Location

Your SQLite database is located at:
```
/app/db.sqlite3  (inside Docker container)
```

Or on your EC2 host machine:
```
/path/to/random-django-app/db.sqlite3
```

---

## 🔑 Method 1: Using Django Admin Panel (Recommended)

### Access Admin Panel

1. **Open your browser and go to:**
   ```
   http://13.233.122.241:9000/admin/
   ```

2. **Login with your superuser credentials** (created during deployment)

3. **Navigate to:**
   - Click on "Users" under "Authentication and Authorization"
   - You'll see all registered users

4. **View User Details:**
   - Click on any username
   - You can see:
     - Username
     - Email
     - Password (hashed - not plain text)
     - Date joined
     - Last login
     - Permissions

**Note:** Django stores passwords as hashes, not plain text (security feature!)

---

## 🐚 Method 2: Using Django Shell (Direct Database Access)

### On EC2 Instance

```bash
# Enter the Django shell
docker-compose exec web python manage.py shell
```

### Inside Django Shell

```python
# Import User model
from django.contrib.auth.models import User

# Get all users
users = User.objects.all()
for user in users:
    print(f"ID: {user.id}, Username: {user.username}, Email: {user.email}")

# Get specific user by username
user = User.objects.get(username='admin')
print(f"User ID: {user.id}")
print(f"Username: {user.username}")
print(f"Email: {user.email}")
print(f"Is Superuser: {user.is_superuser}")
print(f"Date Joined: {user.date_joined}")

# Get specific user by ID
user = User.objects.get(id=1)
print(f"Username: {user.username}")

# Check if password is correct (verify password)
user = User.objects.get(username='admin')
is_correct = user.check_password('your_password_here')
print(f"Password correct: {is_correct}")

# Get all user information
from django.contrib.auth.models import User
for user in User.objects.all():
    print("=" * 50)
    print(f"ID: {user.id}")
    print(f"Username: {user.username}")
    print(f"Email: {user.email}")
    print(f"First Name: {user.first_name}")
    print(f"Last Name: {user.last_name}")
    print(f"Is Staff: {user.is_staff}")
    print(f"Is Active: {user.is_active}")
    print(f"Is Superuser: {user.is_superuser}")
    print(f"Date Joined: {user.date_joined}")
    print(f"Last Login: {user.last_login}")
    print(f"Password Hash: {user.password}")

# Exit shell
exit()
```

---

## 🗄️ Method 3: Direct SQLite Database Query

### Access SQLite Database on EC2

```bash
# Option A: Access from inside container
docker-compose exec web sqlite3 /app/db.sqlite3

# Option B: Access from host (if db.sqlite3 is volume-mounted)
cd /path/to/random-django-app
sqlite3 db.sqlite3
```

### Inside SQLite Shell

```sql
-- List all tables
.tables

-- View users table schema
.schema auth_user

-- Get all users
SELECT id, username, email, is_staff, is_superuser, date_joined 
FROM auth_user;

-- Get specific user by username
SELECT * FROM auth_user WHERE username='admin';

-- Get user ID and username only
SELECT id, username FROM auth_user;

-- Get superusers only
SELECT id, username, email FROM auth_user WHERE is_superuser=1;

-- Count total users
SELECT COUNT(*) FROM auth_user;

-- View password hash (not plain text!)
SELECT username, password FROM auth_user;

-- Exit SQLite
.quit
```

---

## 📊 Method 4: Using Django Management Command

### Create a Custom Management Command

```bash
# On EC2
docker-compose exec web python manage.py shell -c "
from django.contrib.auth.models import User
users = User.objects.all().values('id', 'username', 'email', 'is_staff', 'is_superuser')
for user in users:
    print(user)
"
```

### One-Liner to Get All Users

```bash
docker-compose exec web python manage.py shell -c "
from django.contrib.auth.models import User; 
[print(f'ID: {u.id}, Username: {u.username}, Email: {u.email}') for u in User.objects.all()]
"
```

---

## 🔓 Method 5: Retrieve Specific User Information

### Get User by ID

```bash
# On EC2
docker-compose exec web python manage.py shell
```

```python
from django.contrib.auth.models import User

# Get user with ID 1
user = User.objects.get(id=1)
print(f"Username: {user.username}")
print(f"Email: {user.email}")
```

### Get User by Username

```python
from django.contrib.auth.models import User

user = User.objects.get(username='admin')
print(f"User ID: {user.id}")
print(f"Email: {user.email}")
```

### Get All Superusers

```python
from django.contrib.auth.models import User

superusers = User.objects.filter(is_superuser=True)
for user in superusers:
    print(f"ID: {user.id}, Username: {user.username}")
```

---

## 🔒 Password Information (IMPORTANT!)

### Understanding Django Passwords

Django **DOES NOT** store passwords in plain text. Instead, it stores:

```
pbkdf2_sha256$<iterations>$<salt>$<hash>
```

**Example:**
```
pbkdf2_sha256$600000$abc123$XYZ789...
```

### Why You Can't Get Plain Text Passwords

1. **Security:** Django uses one-way hashing (PBKDF2 algorithm)
2. **Cannot be reversed:** Hash → Plain text is impossible
3. **Can only verify:** Check if a password matches the hash

### How to Verify a Password

```python
from django.contrib.auth.models import User

user = User.objects.get(username='admin')
is_correct = user.check_password('test_password')
print(is_correct)  # True or False
```

### How to Reset a Password

```python
from django.contrib.auth.models import User

user = User.objects.get(username='admin')
user.set_password('new_password_here')
user.save()
print("Password updated successfully!")
```

Or using command line:

```bash
docker-compose exec web python manage.py changepassword admin
```

---

## 📋 Quick Reference Commands

### Get All User IDs and Usernames

```bash
docker-compose exec web python manage.py shell -c "
from django.contrib.auth.models import User
for u in User.objects.all():
    print(f'ID: {u.id} | Username: {u.username} | Email: {u.email}')
"
```

### Get User Count

```bash
docker-compose exec web python manage.py shell -c "
from django.contrib.auth.models import User
print(f'Total Users: {User.objects.count()}')
"
```

### Get Superuser Information

```bash
docker-compose exec web python manage.py shell -c "
from django.contrib.auth.models import User
for u in User.objects.filter(is_superuser=True):
    print(f'Superuser - ID: {u.id}, Username: {u.username}')
"
```

### Export Users to JSON

```bash
docker-compose exec web python manage.py dumpdata auth.user --indent 2 > users.json
```

### View User Data in Table Format

```bash
docker-compose exec web sqlite3 /app/db.sqlite3 <<EOF
.mode column
.headers on
SELECT id, username, email, is_superuser, date_joined FROM auth_user;
EOF
```

---

## 🎯 Common Use Cases

### 1. Forgot Admin Username

```bash
docker-compose exec web python manage.py shell -c "
from django.contrib.auth.models import User
admin = User.objects.filter(is_superuser=True).first()
print(f'Admin Username: {admin.username}')
"
```

### 2. Forgot Admin Password - Reset It

```bash
docker-compose exec web python manage.py changepassword admin
```

Or create new superuser:

```bash
docker-compose exec web python manage.py createsuperuser
```

### 3. Check if User Exists

```bash
docker-compose exec web python manage.py shell -c "
from django.contrib.auth.models import User
exists = User.objects.filter(username='testuser').exists()
print(f'User exists: {exists}')
"
```

### 4. Get Last Login Information

```bash
docker-compose exec web python manage.py shell -c "
from django.contrib.auth.models import User
for u in User.objects.all():
    print(f'{u.username} - Last Login: {u.last_login}')
"
```

---

## 🛡️ Security Best Practices

### DO:
✅ Use Django Admin panel for user management  
✅ Use `check_password()` to verify passwords  
✅ Use `set_password()` to change passwords  
✅ Keep database file secure (proper permissions)  
✅ Use environment variables for sensitive data  

### DON'T:
❌ Never store passwords in plain text  
❌ Don't share password hashes publicly  
❌ Don't expose database file to public access  
❌ Don't log passwords in application logs  
❌ Don't commit `.env` file with credentials to Git  

---

## 📁 Database File Location Reference

### Inside Docker Container

```
/app/db.sqlite3
```

### On EC2 Host Machine

```
/home/ec2-user/random-django-app/db.sqlite3
```

Or wherever you cloned the repository.

### Check Database File

```bash
# On EC2
ls -lh db.sqlite3

# Check size and permissions
stat db.sqlite3

# Inside container
docker-compose exec web ls -lh /app/db.sqlite3
```

---

## 🔍 Troubleshooting

### Database Locked Error

```bash
# Stop all containers
docker-compose down

# Start again
docker-compose up -d web
```

### Can't Access Database

```bash
# Check if file exists
docker-compose exec web ls -la /app/db.sqlite3

# Check permissions
docker-compose exec web stat /app/db.sqlite3
```

### User Not Found

```bash
# Create a new superuser
docker-compose exec web python manage.py createsuperuser
```

---

## 📞 Quick Access Summary

| Method | Command | Use Case |
|--------|---------|----------|
| **Admin Panel** | `http://13.233.122.241:9000/admin/` | GUI access to all users |
| **Django Shell** | `docker-compose exec web python manage.py shell` | Programmatic access |
| **SQLite Direct** | `docker-compose exec web sqlite3 /app/db.sqlite3` | Direct database queries |
| **One-Liner** | `docker-compose exec web python manage.py shell -c "..."` | Quick commands |
| **Reset Password** | `docker-compose exec web python manage.py changepassword` | Password reset |

---

## ✅ Complete Example: Get All User Information

```bash
# On EC2 - Run this complete script
docker-compose exec web python manage.py shell <<EOF
from django.contrib.auth.models import User

print("=" * 60)
print("ALL USERS IN DATABASE")
print("=" * 60)

for user in User.objects.all():
    print(f"\nUser ID: {user.id}")
    print(f"Username: {user.username}")
    print(f"Email: {user.email}")
    print(f"Full Name: {user.first_name} {user.last_name}")
    print(f"Is Superuser: {user.is_superuser}")
    print(f"Is Staff: {user.is_staff}")
    print(f"Is Active: {user.is_active}")
    print(f"Date Joined: {user.date_joined}")
    print(f"Last Login: {user.last_login}")
    print("-" * 60)

print(f"\nTotal Users: {User.objects.count()}")
print(f"Superusers: {User.objects.filter(is_superuser=True).count()}")
print(f"Active Users: {User.objects.filter(is_active=True).count()}")
EOF
```

---

**📝 Remember:** Django passwords are **HASHED** and **CANNOT** be retrieved in plain text. This is a security feature, not a limitation!

**🔗 Access your admin panel at:** http://13.233.122.241:9000/admin/
