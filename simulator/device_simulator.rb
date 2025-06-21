require 'net/http'
require 'uri'
require 'json'
require 'time' # For accurate timestamps
require 'pry'

# Load Rails environment to access models
require_relative '../config/environment'

# Configuration for the API endpoint (configurable via environment variables)
API_HOST = ENV.fetch('API_HOST', '0.0.0.0')
API_PORT = ENV.fetch('API_PORT', '5000').to_i
API_PATH = '/api/v1/devices/status'
API_URL = URI("http://#{API_HOST}:#{API_PORT}#{API_PATH}")

# Configuration for simulation
SIMULATION_CONFIG = {
  'status_change_probability' => 0.40, # 10% chance of status change per device per cycle
  'update_interval_seconds' => 5 # Send updates every 5 seconds
}

# Available device statuses (using enum keys from Device model)
DEVICE_STATUSES = ['active', 'warning', 'critical', 'inactive']

# Status weights for more realistic distribution (higher weight = more common)
STATUS_WEIGHTS = {
  'active' => 90,    # 80% chance - most common
  'inactive' => 1,  # 5% chance - moderately common
  'warning' => 7,    # 10% chance - less common
  'critical' => 2    # 5% chance - very rare
}

# Function to select status based on weights
def select_weighted_status(exclude_status = nil)
  available_statuses = exclude_status ? DEVICE_STATUSES - [exclude_status] : DEVICE_STATUSES
  available_weights = available_statuses.map { |status| STATUS_WEIGHTS[status] }
  total_weight = available_weights.sum
  
  random_value = rand(total_weight)
  cumulative_weight = 0
  
  available_statuses.each_with_index do |status, index|
    cumulative_weight += available_weights[index]
    return status if random_value < cumulative_weight
  end
  
  available_statuses.last # Fallback
end

# Load restaurant and device data from database
def load_device_data_from_database
  puts "Loading restaurant and device data from database..."
  
  restaurants_data = []
  
  Restaurant.includes(:devices).find_each do |restaurant|
    restaurant_data = {
      'name' => restaurant.name,
      'location' => restaurant.location,
      'address' => restaurant.address,
      'email' => restaurant.email,
      'phone' => restaurant.phone,
      'timezone' => restaurant.timezone,
      'status' => restaurant.status,
      'devices' => []
    }
    
    restaurant.devices.each do |device|
      device_data = {
        'name' => device.name,
        'device_type' => device.device_type,
        'model' => device.model,
        'serial_number' => device.serial_number,
        'status' => device.status
      }
      restaurant_data['devices'] << device_data
    end
    
    restaurants_data << restaurant_data
  end
  
  puts "Loaded #{restaurants_data.length} restaurants with #{restaurants_data.sum { |r| r['devices'].length }} devices"
  restaurants_data
end

# Load configuration and data
RESTAURANTS = load_device_data_from_database

# Function to send data to the API
def send_device_status_update(payload)
  http = Net::HTTP.new(API_URL.host, API_URL.port)
  request = Net::HTTP::Post.new(API_URL)
  request['Content-Type'] = 'application/json'
  request.body = { device: payload }.to_json

  begin
    response = http.request(request)
    puts "[#{Time.now.strftime('%H:%M:%S')}] ✅ #{payload[:name]} (#{payload[:serial_number]}) - Status: #{payload[:status]}"
    puts "   Response: #{response.code} - #{response.body.strip}"
  rescue Net::HTTPClientException => e
    puts "[#{Time.now.strftime('%H:%M:%S')}] ❌ Network error for #{payload[:serial_number]}: #{e.message}"
  rescue StandardError => e
    puts "[#{Time.now.strftime('%H:%M:%S')}] ❌ Unexpected error for #{payload[:serial_number]}: #{e.message}"
  end
end

# Main simulation loop
def run_simulation
  puts "Starting restaurant device simulation..."
  puts "Sending updates to #{API_URL}"
  puts "Loaded #{RESTAURANTS.length} restaurants with #{RESTAURANTS.sum { |r| r['devices'].length }} devices"

  # Keep track of device states to simulate changes more realistically
  device_current_states = {}
  RESTAURANTS.each do |restaurant|
    restaurant['devices'].each do |device|
      device_current_states[device['serial_number']] = {
        restaurant_name: restaurant['name'],
        device_type: device['device_type'],
        device_name: device['name'],
        model: device['model'],
        current_status: device['status'],
        description: "Initial #{device['status']} status"
      }
    end
  end

  loop do
    # Iterate through all devices and potentially update their status
    device_current_states.each do |serial_number, data|
      current_status = data[:current_status]
      new_status = current_status

      # Simulate status changes based on configuration
      if rand < SIMULATION_CONFIG['status_change_probability']
        new_status = select_weighted_status(current_status)

        description = case new_status
                      when 'warning' then "Device #{data[:device_name]} (#{serial_number}) is experiencing intermittent issues."
                      when 'critical' then "Device #{data[:device_name]} (#{serial_number}) is experiencing critical issues."
                      when 'active' then "Device #{data[:device_name]} (#{serial_number}) is back to operational."
                      when 'inactive' then "Device #{data[:device_name]} (#{serial_number}) is currently inactive."
                      else "Device #{data[:device_name]} (#{serial_number}) is unknown."
                      end
        data[:current_status] = new_status
        data[:description] = description
      end

      # Prepare payload for API
      payload = {
        serial_number: serial_number,
        device_type: data[:device_type],
        name: data[:device_name],
        model: data[:model],
        status: data[:current_status],
        description: data[:description],
        reported_at: Time.now.utc.iso8601 # ISO 8601 format for consistency
      }
      payload[:restaurant_name] = data[:restaurant_name] # Include restaurant data for first time creation

      send_device_status_update(payload)
    end

    sleep SIMULATION_CONFIG['update_interval_seconds'] # Send updates based on configuration
  end
end

# Run the simulation
run_simulation