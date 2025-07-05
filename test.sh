#!/bin/bash

# Test script for Writer app
# Runs unit tests and generates coverage report

set -e  # Exit on any error

echo "🧪 Running unit tests with coverage..."
echo "======================================"

# Run tests with coverage
pnpm run test:coverage

echo ""
echo "✅ Tests completed successfully!"
echo "📊 Coverage report generated in coverage/ directory"
echo "📝 Open coverage/lcov-report/index.html to view detailed coverage report"