#!/bin/bash

# Restaurant POS App Test Runner
# This script runs all tests and generates coverage reports

set -e

echo "🧪 Restaurant POS App Test Runner"
echo "=================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    print_error "Flutter is not installed or not in PATH"
    exit 1
fi

# Check Flutter version
FLUTTER_VERSION=$(flutter --version | head -n 1)
print_status "Using $FLUTTER_VERSION"

# Clean previous test results
print_status "Cleaning previous test results..."
flutter clean
flutter pub get

# Create coverage directory
mkdir -p coverage

# Run unit tests
print_status "Running unit tests..."
if flutter test test/unit/ --coverage --reporter=expanded; then
    print_success "Unit tests passed"
else
    print_error "Unit tests failed"
    exit 1
fi

# Run widget tests
print_status "Running widget tests..."
if flutter test test/widget/ --coverage --reporter=expanded; then
    print_success "Widget tests passed"
else
    print_error "Widget tests failed"
    exit 1
fi

# Run integration tests
print_status "Running integration tests..."
if flutter test integration_test/ --reporter=expanded; then
    print_success "Integration tests passed"
else
    print_warning "Integration tests failed (this is expected in CI without devices)"
fi

# Generate coverage report
print_status "Generating coverage report..."

# Check if lcov is installed
if command -v genhtml &> /dev/null; then
    genhtml coverage/lcov.info -o coverage/html --title "Restaurant POS App Coverage"
    print_success "Coverage report generated at coverage/html/index.html"
else
    print_warning "genhtml not found. Install lcov to generate HTML coverage report:"
    print_warning "  - macOS: brew install lcov"
    print_warning "  - Ubuntu: sudo apt-get install lcov"
    print_warning "  - Windows: Install lcov via package manager"
fi

# Display coverage summary
if [ -f "coverage/lcov.info" ]; then
    print_status "Coverage summary:"
    
    # Extract coverage percentage (basic parsing)
    TOTAL_LINES=$(grep -c "^LF:" coverage/lcov.info || echo "0")
    HIT_LINES=$(grep -c "^LH:" coverage/lcov.info || echo "0")
    
    if [ "$TOTAL_LINES" -gt 0 ]; then
        COVERAGE_PERCENT=$((HIT_LINES * 100 / TOTAL_LINES))
        print_status "Total lines: $TOTAL_LINES"
        print_status "Hit lines: $HIT_LINES"
        print_status "Coverage: $COVERAGE_PERCENT%"
        
        if [ "$COVERAGE_PERCENT" -ge 80 ]; then
            print_success "Coverage meets minimum requirement (80%)"
        else
            print_warning "Coverage is below minimum requirement (80%)"
        fi
    fi
fi

# Run code analysis
print_status "Running code analysis..."
if flutter analyze; then
    print_success "Code analysis passed"
else
    print_error "Code analysis failed"
    exit 1
fi

# Check code formatting
print_status "Checking code formatting..."
if flutter format --dry-run --set-exit-if-changed .; then
    print_success "Code formatting is correct"
else
    print_warning "Code formatting issues found. Run 'flutter format .' to fix them."
fi

# Summary
echo ""
echo "🎉 Test Summary"
echo "==============="
print_success "All tests completed successfully!"
print_status "Coverage report: coverage/html/index.html"
print_status "LCOV file: coverage/lcov.info"

# Open coverage report if on macOS
if [[ "$OSTYPE" == "darwin"* ]] && [ -d "coverage/html" ]; then
    read -p "Open coverage report in browser? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        open coverage/html/index.html
    fi
fi

echo ""
print_success "Test runner completed successfully! 🚀"
