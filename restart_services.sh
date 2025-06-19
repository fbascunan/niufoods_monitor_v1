#!/bin/bash

echo "🛑 Stopping all services..."
pkill -f "foreman start" || true
pkill -f "sidekiq" || true
pkill -f "puma" || true

echo "🧹 Clearing Redis queues..."
redis-cli flushall || echo "Redis not running or not accessible"

echo "⏳ Waiting 3 seconds..."
sleep 3

echo "🚀 Starting services with foreman..."
foreman start 