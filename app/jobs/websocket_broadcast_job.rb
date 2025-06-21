class WebsocketBroadcastJob < ApplicationJob
  queue_as :default
  include ActionView::Helpers::DateHelper

  # Configure unique jobs to prevent duplicates for the same restaurant
  sidekiq_options unique: :until_executed, unique_args: :unique_args

  def self.unique_args(args)
    [args[0]] # Only use restaurant_id for uniqueness
  end

  def perform(restaurant_id, old_restaurant_status = nil)
    restaurant = Restaurant.includes(:devices).find(restaurant_id)
    old_restaurant_status ||= restaurant.status_was || restaurant.status
    
    # Map statuses to CSS-friendly format
    status_mapping = {
      'activo' => 'operational',
      'advertencia' => 'warning', 
      'critico' => 'critical',
      'inactivo' => 'inactive'
    }

    # Prepare restaurant data
    restaurant_data = {
      id: restaurant.id,
      name: restaurant.name,
      location: restaurant.location,
      status: status_mapping[restaurant.status] || restaurant.status,
      old_status: status_mapping[old_restaurant_status] || old_restaurant_status,
      devices_count: restaurant.devices.count,
      updated_ago: time_ago_in_words(restaurant.updated_at)
    }

    # Prepare all devices data
    devices_data = restaurant.devices.map do |device|
      {
        device_id: device.id,
        restaurant_id: restaurant.id,
        name: device.name,
        device_type: device.device_type,
        status: status_mapping[device.status] || device.status,
        model: device.model,
        serial_number: device.serial_number,
        last_check_in_at: device.last_check_in_at,
        updated_ago: time_ago_in_words(device.updated_at)
      }
    end

    # Send full restaurant update via WebSocket
    ActionCable.server.broadcast("restaurants_channel", {
      restaurant: restaurant_data,
      devices: devices_data,
      timestamp: Time.current
    })
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error("WebsocketBroadcastJob: Restaurant not found - #{e.message}")
  rescue StandardError => e
    Rails.logger.error("WebsocketBroadcastJob: Error broadcasting update - #{e.message}")
  end
end 