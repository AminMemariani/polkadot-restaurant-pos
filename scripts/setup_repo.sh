#!/bin/bash

# Restaurant POS App - Repository Setup Script
# This script helps set up the repository for GitHub Actions

echo "🚀 Setting up Restaurant POS App repository..."

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo "❌ Not in a git repository. Please run 'git init' first."
    exit 1
fi

# Check if remote origin is set
if ! git remote get-url origin > /dev/null 2>&1; then
    echo "⚠️  No remote origin set. Please add your GitHub repository:"
    echo "   git remote add origin https://github.com/cyberhonig/restaurant_pos_app.git"
    echo "   git branch -M main"
    echo "   git push -u origin main"
    exit 1
fi

echo "✅ Git repository is properly configured"

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter first."
    exit 1
fi

echo "✅ Flutter is installed"

# Run Flutter doctor to check setup
echo "🔍 Checking Flutter setup..."
flutter doctor

# Get dependencies
echo "📦 Getting Flutter dependencies..."
flutter pub get

# Run tests to ensure everything works
echo "🧪 Running tests..."
flutter test

# Check if tests passed
if [ $? -eq 0 ]; then
    echo "✅ All tests passed!"
else
    echo "❌ Some tests failed. Please fix them before pushing to GitHub."
    exit 1
fi

# Format code
echo "🎨 Formatting code..."
flutter format .

# Analyze code
echo "🔍 Analyzing code..."
flutter analyze

echo ""
echo "🎉 Repository setup complete!"
echo ""
echo "📋 Next steps:"
echo "1. Commit your changes:"
echo "   git add ."
echo "   git commit -m 'Initial commit with working tests'"
echo ""
echo "2. Push to GitHub:"
echo "   git push origin main"
echo ""
echo "3. Check GitHub Actions:"
echo "   https://github.com/cyberhonig/restaurant_pos_app/actions"
echo ""
echo "4. The badges in README.md will work after the first push!"
echo ""
