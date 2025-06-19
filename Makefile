# NiuFoods Monitor v1 - Makefile
# Common Docker operations for easy project management

.PHONY: help setup start stop restart logs test clean simulator build

# Default target
help:
	@echo "🚀 NiuFoods Monitor v1 - Available Commands"
	@echo "=========================================="
	@echo ""
	@echo "📦 Setup & Installation:"
	@echo "  setup     - Complete setup (build, start, migrate, seed)"
	@echo "  build     - Build Docker images"
	@echo ""
	@echo "🔄 Service Management:"
	@echo "  start     - Start all services"
	@echo "  stop      - Stop all services"
	@echo "  restart   - Restart all services"
	@echo "  logs      - View logs from all services"
	@echo ""
	@echo "🧪 Testing & Development:"
	@echo "  test      - Run test suite"
	@echo "  simulator - Start device simulator"
	@echo "  console   - Open Rails console"
	@echo ""
	@echo "🧹 Maintenance:"
	@echo "  clean     - Stop services and remove containers/volumes"
	@echo "  reset     - Clean and setup from scratch"
	@echo ""
	@echo "📊 Status:"
	@echo "  status    - Show service status"
	@echo "  ps        - Show running containers"

# Setup everything from scratch
setup:
	@echo "🚀 Setting up NiuFoods Monitor v1..."
	@chmod +x docker-setup.sh
	@./docker-setup.sh

# Build Docker images
build:
	@echo "🔨 Building Docker images..."
	docker-compose build

# Start all services
start:
	@echo "▶️  Starting services..."
	docker-compose up -d

# Stop all services
stop:
	@echo "⏹️  Stopping services..."
	docker-compose down

# Restart all services
restart:
	@echo "🔄 Restarting services..."
	docker-compose restart

# View logs
logs:
	@echo "📋 Viewing logs..."
	docker-compose logs -f

# Run tests
test:
	@echo "🧪 Running tests..."
	docker-compose exec web bundle exec rails test

# Start simulator
simulator:
	@echo "🎮 Starting device simulator..."
	docker-compose --profile simulator up simulator

# Open Rails console
console:
	@echo "💻 Opening Rails console..."
	docker-compose exec web bundle exec rails console

# Show service status
status:
	@echo "📊 Service Status:"
	docker-compose ps

# Alias for status
ps: status

# Clean everything
clean:
	@echo "🧹 Cleaning up..."
	docker-compose down -v --remove-orphans
	docker system prune -f

# Reset everything and setup from scratch
reset: clean setup

# Quick development commands
dev-logs:
	@echo "📋 Viewing development logs..."
	docker-compose logs -f web sidekiq

dev-restart:
	@echo "🔄 Restarting development services..."
	docker-compose restart web sidekiq

# Database operations
db-migrate:
	@echo "🗄️  Running database migrations..."
	docker-compose exec web bundle exec rails db:migrate

db-seed:
	@echo "🌱 Seeding database..."
	docker-compose exec web bundle exec rails db:seed

db-reset:
	@echo "🔄 Resetting database..."
	docker-compose exec web bundle exec rails db:drop db:create db:migrate db:seed 