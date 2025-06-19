#!/bin/bash

# NiuFoods Monitor v1 - Docker Setup Script
# This script sets up and runs the entire NiuFoods monitoring system using Docker

set -e

echo "🚀 NiuFoods Monitor v1 - Docker Setup"
echo "======================================"

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

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    print_error "Docker is not running. Please start Docker and try again."
    exit 1
fi

# Check if Docker Compose is available
if ! docker-compose --version > /dev/null 2>&1; then
    print_error "Docker Compose is not installed. Please install Docker Compose and try again."
    exit 1
fi

print_status "Building Docker images..."
docker-compose build

print_status "Starting services..."
docker-compose up -d postgres redis

print_status "Waiting for database to be ready..."
sleep 10

print_status "Setting up database..."
docker-compose exec web bundle exec rails db:create
docker-compose exec web bundle exec rails db:migrate
docker-compose exec web bundle exec rails db:seed

print_status "Starting web application and Sidekiq..."
docker-compose up -d web sidekiq

print_success "Setup complete! 🎉"
echo ""
echo "📊 Services Status:"
echo "=================="
docker-compose ps
echo ""
echo "🌐 Access Points:"
echo "================"
echo "• Dashboard: http://localhost:5000"
echo "• API Base: http://localhost:5000/api/v1"
echo "• Sidekiq Dashboard: http://localhost:5000/sidekiq"
echo ""
echo "📝 Useful Commands:"
echo "=================="
echo "• View logs: docker-compose logs -f"
echo "• Stop services: docker-compose down"
echo "• Restart services: docker-compose restart"
echo "• Run simulator: docker-compose --profile simulator up simulator"
echo "• Run tests: docker-compose exec web bundle exec rails test"
echo ""
print_warning "The simulator is not running by default. To start it, run:"
echo "docker-compose --profile simulator up simulator"
echo ""
print_success "Your NiuFoods Monitor is ready! 🚀" 