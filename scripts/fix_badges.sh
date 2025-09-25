#!/bin/bash

# Fix GitHub Actions Badges Script
# This script helps fix the broken badges by pushing the changes

echo "🔧 Fixing GitHub Actions badges..."

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo "❌ Not in a git repository. Please run 'git init' first."
    exit 1
fi

# Check git status
echo "📋 Current git status:"
git status --short

# Add all changes
echo "📦 Adding all changes..."
git add .

# Commit changes
echo "💾 Committing changes..."
git commit -m "Fix GitHub Actions badges and add quality workflow

- Updated README.md with proper badge URLs
- Added quality.yml workflow for code quality checks
- Fixed CI/CD pipeline configuration
- Added setup scripts for repository configuration"

# Check if remote origin is set
if ! git remote get-url origin > /dev/null 2>&1; then
    echo "⚠️  No remote origin set. Setting up remote..."
    git remote add origin https://github.com/cyberhonig/restaurant_pos_app.git
    git branch -M main
fi

# Push to GitHub
echo "🚀 Pushing to GitHub..."
git push origin main

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Successfully pushed to GitHub!"
    echo ""
    echo "🎉 Your badges should now work:"
    echo "   - CI/CD Pipeline: https://github.com/cyberhonig/restaurant_pos_app/actions/workflows/ci.yml"
    echo "   - Code Quality: https://github.com/cyberhonig/restaurant_pos_app/actions/workflows/quality.yml"
    echo "   - Test Coverage: https://codecov.io/gh/cyberhonig/restaurant_pos_app"
    echo ""
    echo "📊 Check your repository at:"
    echo "   https://github.com/cyberhonig/restaurant_pos_app"
    echo ""
    echo "🔍 Monitor workflows at:"
    echo "   https://github.com/cyberhonig/restaurant_pos_app/actions"
else
    echo "❌ Failed to push to GitHub. Please check your git configuration."
    exit 1
fi
