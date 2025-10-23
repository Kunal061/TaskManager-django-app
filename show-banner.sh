#!/bin/bash

# Display project banner

clear

if [ -f "BANNER.txt" ]; then
    cat BANNER.txt
else
    echo "Django Task Manager - Production Ready!"
    echo "========================================"
    echo ""
    echo "✅ All files created successfully!"
    echo ""
    echo "📚 Documentation available:"
    echo "  - README.md"
    echo "  - QUICKSTART.md"
    echo "  - EC2_DEPLOYMENT_GUIDE.md"
    echo "  - And more in INDEX.md"
    echo ""
    echo "🚀 Quick start:"
    echo "  docker-compose up -d --build"
    echo ""
fi

echo ""
echo "Press any key to continue..."
read -n 1 -s
