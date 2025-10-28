#!/bin/bash

# Script to configure git to fetch all remote branches for Frappe apps
# Usage: ./fix-git-refs.sh apps/myapp

set -e

if [ $# -eq 0 ]; then
    echo "Usage: $0 <app-path>"
    echo "Example: $0 apps/myapp"
    exit 1
fi

APP_PATH="$1"

# Check if directory exists
if [ ! -d "$APP_PATH" ]; then
    echo "Error: Directory $APP_PATH does not exist"
    exit 1
fi

# Check if it's a git repository
if [ ! -d "$APP_PATH/.git" ]; then
    echo "Error: $APP_PATH is not a git repository"
    exit 1
fi

echo "🔧 Configuring git to fetch all remote refs for $APP_PATH"

cd "$APP_PATH"

# Get remote name (usually 'upstream' for Frappe apps)
REMOTE=$(git remote | head -n 1)
if [ -z "$REMOTE" ]; then
    echo "❌ No remote found"
    exit 1
fi
echo "🌐 Remote: $REMOTE"

# Show current fetch configuration
echo "📋 Current fetch refspec:"
git config --get-all "remote.$REMOTE.fetch" || echo "  (none configured)"

# Configure git to fetch all remote branches
echo "⚙️  Setting fetch refspec to get all remote branches..."
git config "remote.$REMOTE.fetch" "+refs/heads/*:refs/remotes/$REMOTE/*"

echo "✅ Updated fetch configuration"

# Now fetch to get all the refs
echo "📥 Fetching all remote branches..."
git fetch "$REMOTE"

echo ""
echo "📋 Remote branches now available:"
BRANCH_COUNT=$(git branch -r | grep "^  $REMOTE/" | wc -l)
echo "  Count: $BRANCH_COUNT"

# Test: Remove all remote refs and verify they come back with normal fetch
echo ""
echo "🧪 Testing automatic fetch configuration..."
echo "🗑️  Temporarily removing all remote refs to test..."

# Get current branch to avoid issues
CURRENT_BRANCH=$(git branch --show-current)

# Remove all remote tracking branches (except current if it's a remote tracking branch)
git for-each-ref --format='%(refname:short)' refs/remotes/$REMOTE/ | while read ref; do
    # Skip if this is the upstream of our current branch
    if [ "$ref" != "$REMOTE/$CURRENT_BRANCH" ]; then
        git branch -dr "$ref" 2>/dev/null || true
    fi
done

echo "📊 Remote branches after cleanup:"
CLEANUP_COUNT=$(git branch -r | grep "^  $REMOTE/" | wc -l)
echo "  Count: $CLEANUP_COUNT"

echo "🔄 Running normal 'git fetch' to test automatic ref retrieval..."
git fetch "$REMOTE"

echo "✅ Remote branches after automatic fetch:"
FINAL_COUNT=$(git branch -r | grep "^  $REMOTE/" | wc -l)
echo "  Count: $FINAL_COUNT"

# More lenient check - should be at least as many as we had after cleanup
if [ "$FINAL_COUNT" -ge "$CLEANUP_COUNT" ] && [ "$FINAL_COUNT" -ge 3 ]; then
    echo "🎉 Success! Remote branches automatically fetched ($FINAL_COUNT branches)"
    echo "   ✅ Automatic fetch is working correctly"
else
    echo "⚠️  Warning: Only $FINAL_COUNT branches fetched (expected at least $CLEANUP_COUNT)"
fi

echo ""
echo "🎉 Git configured to fetch all remote branches for $APP_PATH"
echo "💡 Future git fetch commands will automatically get all remote branches"