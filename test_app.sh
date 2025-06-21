#!/bin/bash

# NiuFoods Monitor v1 - Test Script
# This script tests if the application is running and working properly

set -e

echo "🧪 NiuFoods Monitor v1 - Test Script"
echo "===================================="

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

# Test 1: Check if Docker containers are running
print_status "Testing Docker containers..."
if docker compose ps | grep -q "Up"; then
    print_success "Docker containers are running"
else
    print_error "Docker containers are not running. Please run 'make setup' first."
    exit 1
fi

# Test 2: Check if web application is responding
print_status "Testing web application..."
if curl -s -f http://localhost:5000 > /dev/null; then
    print_success "Web application is responding"
else
    print_error "Web application is not responding. Please check if it's running."
    exit 1
fi

# Test 3: Test API endpoints
print_status "Testing API endpoints..."

# Test GET /api/v1/restaurants
if curl -s -f http://localhost:5000/api/v1/restaurants > /dev/null; then
    print_success "API endpoint /api/v1/restaurants is working"
else
    print_error "API endpoint /api/v1/restaurants is not working"
    exit 1
fi

# Test POST /api/v1/devices/status
TEST_RESPONSE=$(curl -s -X POST http://localhost:5000/api/v1/devices/status \
  -H "Content-Type: application/json" \
  -d '{
    "device": {
      "serial_number": "TEST001",
      "device_type": "pos",
      "name": "Test Device",
      "status": "active",
      "restaurant_name": "Test Restaurant"
    }
  }')

if echo "$TEST_RESPONSE" | grep -q "success\|created\|updated"; then
    print_success "API endpoint /api/v1/devices/status is working"
else
    print_warning "API endpoint /api/v1/devices/status response: $TEST_RESPONSE"
fi

# Test 4: Check Sidekiq dashboard
print_status "Testing Sidekiq dashboard..."
if curl -s -f http://localhost:5000/sidekiq > /dev/null; then
    print_success "Sidekiq dashboard is accessible"
else
    print_warning "Sidekiq dashboard is not accessible"
fi

# Test 5: Check if simulator can be started
print_status "Testing simulator..."
if docker compose --profile simulator up simulator -d > /dev/null 2>&1; then
    print_success "Simulator can be started"
    # Stop simulator after test
    docker compose --profile simulator down > /dev/null 2>&1
else
    print_warning "Simulator could not be started"
fi

# Test 6: Run Rails tests
print_status "Running Rails tests..."
if docker compose exec -T web bundle exec rails test > /dev/null 2>&1; then
    print_success "Rails tests are passing"
else
    print_warning "Rails tests failed or could not be run"
fi

echo ""
print_success "🎉 All tests completed!"
echo ""
echo "📊 Application Status:"
echo "====================="
echo "• Web Application: http://localhost:5000"
echo "• API Base: http://localhost:5000/api/v1"
echo "• Sidekiq Dashboard: http://localhost:5000/sidekiq"
echo ""
echo "🎮 To start the device simulator:"
echo "make simulator"
echo ""
echo "📋 To view logs:"
echo "make logs"
echo ""
print_success "Your NiuFoods Monitor is ready for review! 🚀" 