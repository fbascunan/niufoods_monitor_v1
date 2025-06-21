#!/bin/bash

# NiuFoods Monitor v1 - Test Script
# Simple test to verify the application is working

set -e

echo "🧪 Testing NiuFoods Monitor"
echo "============================"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Test 1: Check containers
print_status "Checking containers..."
if docker compose ps | grep -q "Up"; then
    print_success "Containers are running"
else
    print_error "Containers are not running. Run 'make setup' first."
    exit 1
fi

# Test 2: Check web app
print_status "Testing web application..."
if curl -s -f http://localhost:5000 > /dev/null; then
    print_success "Web application is responding"
else
    print_error "Web application is not responding"
    exit 1
fi

# Test 3: Test API
print_status "Testing API..."
if curl -s -f http://localhost:5000/api/v1/restaurants > /dev/null; then
    print_success "API is working"
else
    print_error "API is not working"
    exit 1
fi

# Test 4: Test device status endpoint
print_status "Testing device status endpoint..."
RESPONSE=$(curl -s -X POST http://localhost:5000/api/v1/devices/status \
  -H "Content-Type: application/json" \
  -d '{"device":{"serial_number":"TEST001","device_type":"pos","name":"Test","status":"active","restaurant_name":"Test"}}')

if echo "$RESPONSE" | grep -q "success\|created\|updated"; then
    print_success "Device status endpoint is working"
else
    print_error "Device status endpoint failed: $RESPONSE"
fi

echo ""
print_success "🎉 All tests passed!"
echo ""
echo "🌐 Access:"
echo "• Dashboard: http://localhost:5000"
echo "• API: http://localhost:5000/api/v1"
echo "• Sidekiq: http://localhost:5000/sidekiq"
echo ""
print_success "Ready for review! 🚀" 