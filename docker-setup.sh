#!/bin/bash

# NiuFoods Monitor v1 - Setup Script
# Simple and robust setup

set -e

echo "🚀 NiuFoods Monitor v1 - Setup"
echo "==============================="

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

# Check Docker
if ! docker info > /dev/null 2>&1; then
    print_error "Docker is not running. Please start Docker and try again."
    exit 1
fi

# Check Docker Compose
if ! docker compose version > /dev/null 2>&1; then
    print_error "Docker Compose is not available. Please install Docker Compose."
    exit 1
fi

print_success "Docker and Docker Compose are ready"

# Clean up any existing containers
print_status "Cleaning up existing containers..."
docker compose down -v 2>/dev/null || true

# Build and start
print_status "Building and starting services..."
docker compose up -d --build

# Wait for services to be ready
print_status "Waiting for services to be ready..."
sleep 15

# Setup database
print_status "Setting up database..."
docker compose exec -T web bundle exec rails db:create db:migrate db:seed

print_success "Setup complete! 🎉"
echo ""
echo "🌐 Access Points:"
echo "• Dashboard: http://localhost:5000"
echo "• API: http://localhost:5000/api/v1"
echo "• Sidekiq: http://localhost:5000/sidekiq"
echo ""
echo "📝 Commands:"
echo "• View logs: make logs"
echo "• Start simulator: make simulator"
echo "• Run tests: make test"
echo ""
print_success "Ready to use! 🚀" 