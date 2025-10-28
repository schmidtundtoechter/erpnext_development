#!/bin/bash

# ================================
# 📦 Frappe App Installation Script
# ================================
echo "🚀 Starting Frappe App Installation..."
echo "======================================"

# Check if in /workspace/development/frappe-bench/
if [ $(basename $(pwd)) != "frappe-bench" ]; then
    echo "❌ ERROR: Please run this script in /workspace/development/frappe-bench/"
    echo "Current directory: $(pwd)"
    echo "Expected directory: /workspace/development/frappe-bench/"
    exit 1
fi

echo "✅ Current directory verified: $(pwd)"

# first argument needs to be github - link
if [ -z "$1" ]; then
    echo "❌ ERROR: No repository URL provided"
    echo "Usage: $0 <github-repository-url>"
    echo "Example: $0 git@github.com:user/repo.git"
    echo "Example: $0 https://github.com/user/repo.git"
    exit 1
fi

echo "📋 Repository URL provided: $1"
originalRepoUrl="$1"

# check that if it is a repository
if [[ $1 != *".git"* ]]; then
    echo "❌ ERROR: Invalid repository URL - must end with .git"
    echo "Provided: $1"
    exit 1
fi

echo "✅ Repository URL format validated"

# Convert SSH URL to HTTPS URL for initial clone
httpsRepoUrl="$originalRepoUrl"

# Simple string matching check
if echo "$originalRepoUrl" | grep -q "^git@github.com:"; then
    # Convert git@github.com:user/repo.git to https://github.com/user/repo.git
    httpsRepoUrl=$(echo "$originalRepoUrl" | sed 's/git@github.com:/https:\/\/github.com\//')
    echo "🔄 Converting SSH URL to HTTPS for initial clone"
    echo "   Original: $originalRepoUrl"
    echo "   HTTPS:    $httpsRepoUrl"
else
    echo "🔄 Using original URL (already HTTPS): $httpsRepoUrl"
fi

# Check wether bench process runs, if so, warn and exit
echo "🔍 Checking if bench is running..."
if [ -z "$(ps -ef | grep 'bench start' | grep -v grep)" ]; then
    echo "✅ bench is not running - safe to proceed"
else
    echo "❌ ERROR: bench is currently running!"
    echo "Please stop bench before running this script:"
    echo "   Press Ctrl+C in the bench start terminal"
    echo "   Or run: pkill -f 'bench start'"
    exit 1
fi

# extract repository name from link
appName=$(echo $originalRepoUrl | rev | cut -d'/' -f 1 | rev | cut -d'.' -f 1) 
echo "📱 Extracted app name: $appName"

# Check if app already exists
if [ -d "apps/$appName" ]; then
    echo "⚠️  WARNING: App '$appName' already exists in apps/ directory"
    echo "Removing existing app to avoid conflicts..."
    rm -rf "apps/$appName"
    echo "✅ Existing app removed"
fi

echo ""
echo "🏗️  STEP 1: Getting app from repository"
echo "========================================"
echo "⏳ Running: bench get-app $httpsRepoUrl"
bench get-app $httpsRepoUrl

if [ $? -eq 0 ]; then
    echo "✅ Successfully downloaded app: $appName"
    
    # If original URL was SSH, update the remote URL to SSH
    if echo "$originalRepoUrl" | grep -q "^git@github.com:"; then
        echo ""
        echo "🔧 STEP 1.5: Updating remote URL to SSH"
        echo "========================================"
        echo "⏳ Changing remote URL from HTTPS to SSH..."
        cd "apps/$appName"
        git remote set-url origin "$originalRepoUrl" 2>/dev/null || echo "⚠️  Note: Could not update remote URL (this is usually harmless)"
        echo "✅ Remote URL updated to: $originalRepoUrl"
        cd ../..
    fi
else
    echo "❌ ERROR: Failed to download app from repository"
    exit 1
fi

echo ""
echo "📦 STEP 2: Installing app on site"
echo "=================================="
echo "⏳ Running: bench --site d-code.localhost install-app $appName"
bench --site d-code.localhost install-app $appName

if [ $? -eq 0 ]; then
    echo "✅ Successfully installed app on site: d-code.localhost"
else
    echo "❌ ERROR: Failed to install app on site"
    exit 1
fi

echo ""
echo "🔄 STEP 3: Running database migration"
echo "====================================="
echo "⏳ Running: bench --site d-code.localhost migrate"
bench --site d-code.localhost migrate

if [ $? -eq 0 ]; then
    echo "✅ Database migration completed successfully"
else
    echo "❌ ERROR: Database migration failed"
    exit 1
fi

echo ""
echo "🏗️  STEP 4: Building assets"
echo "============================"
echo "⏳ Running: bench build"
bench build

if [ $? -eq 0 ]; then
    echo "✅ Assets built successfully"
else
    echo "❌ ERROR: Asset building failed"
    exit 1
fi

echo ""
echo "🎉 INSTALLATION COMPLETED SUCCESSFULLY!"
echo "======================================="
echo "App '$appName' has been installed and configured."
echo ""
echo "🚀 Next steps:"
echo "   1. Start bench: bench start"
echo "   2. Open browser: http://d-code.localhost:8000"
echo "   3. Login with: Administrator / admin"
echo ""
echo "✨ Happy coding! ✨"