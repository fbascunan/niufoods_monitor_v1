#!/usr/bin/env ruby

# Simple test script to verify WebSocket broadcasting
require_relative 'config/environment'
include ActionView::Helpers::DateHelper

puts "Testing WebSocket broadcast..."

# Find a restaurant
restaurant = Restaurant.first
if restaurant
  puts "Found restaurant: #{restaurant.name} (ID: #{restaurant.id})"
  puts "Current status: #{restaurant.status}"
  
  # Store old status
  old_status = restaurant.status
  
  # Update status to trigger broadcast
  restaurant.update!(status: :warning)
  restaurant.recalculate_status
  
  puts "Updated status to: #{restaurant.status}"
  
  # Manually broadcast
  status_mapping = {
    'activo' => 'operational',
    'advertencia' => 'warning', 
    'critico' => 'problems',
    'inactivo' => 'inactive'
  }
  
  ActionCable.server.broadcast("restaurants_channel", {
    id: restaurant.id,
    name: restaurant.name,
    status: status_mapping[restaurant.status] || restaurant.status,
    old_status: status_mapping[old_status] || old_status,
    devices_count: restaurant.devices.count,
    updated_ago: time_ago_in_words(restaurant.updated_at)
  })
  
  puts "WebSocket broadcast sent!"
else
  puts "No restaurants found. Please run the seeds first."
end 