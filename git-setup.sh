#!/bin/bash

# Initialize Git repository and prepare for GitHub

echo "🎯 Initializing Git repository..."

# Initialize git if not already done
if [ ! -d .git ]; then
    git init
    echo "✅ Git repository initialized"
else
    echo "ℹ️  Git repository already exists"
fi

# Add all files
echo "📦 Adding files to git..."
git add .

# Create initial commit
echo "💾 Creating initial commit..."
git commit -m "Initial commit: Django Task Manager with Docker

- Complete Django task management application
- Full CRUD operations for tasks
- Modern responsive UI with Bootstrap 5
- Docker and Docker Compose configuration
- PostgreSQL database integration
- Production-ready deployment setup
- Comprehensive documentation
- EC2 deployment guide included
- Port 9000 configuration for EC2 hosting

Features:
- Task priority levels (Low, Medium, High)
- Status tracking (Pending, In Progress, Completed)
- Due date management
- Filter and pagination
- Admin panel
- Gunicorn WSGI server
- WhiteNoise static file serving

Ready for EC2 deployment!"

echo ""
echo "✅ Git setup complete!"
echo ""
echo "📋 Next steps to push to GitHub:"
echo ""
echo "1. Create a new repository on GitHub (https://github.com/new)"
echo "   - Name it: random-django-app (or your preferred name)"
echo "   - Don't initialize with README (we already have one)"
echo ""
echo "2. Add the remote repository:"
echo "   git remote add origin https://github.com/YOUR-USERNAME/random-django-app.git"
echo ""
echo "3. Rename branch to main (if needed):"
echo "   git branch -M main"
echo ""
echo "4. Push to GitHub:"
echo "   git push -u origin main"
echo ""
echo "5. For EC2 deployment, clone with:"
echo "   git clone https://github.com/YOUR-USERNAME/random-django-app.git"
echo ""
echo "🎉 Repository ready for deployment!"
