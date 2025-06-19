require 'net/http'
require 'uri'
require 'json'
require 'time' # For accurate timestamps
require 'pry'

# Configuration for the API endpoint
API_HOST = '0.0.0.0'
API_PORT = 5000
API_PATH = '/api/v1/devices/status'
API_URL = URI("http://#{API_HOST}:#{API_PORT}#{API_PATH}")

# Define restaurant and device data matching the seeds
RESTAURANTS = [
  {
    name: 'Niu Sushi - Bar&Delivery',
    location: 'Providencia, Santiago',
    devices: [
      { serial_number: 'POS-1-1-7286A78B', device_type: 'pos', name: 'POS Terminal 1' },
      { serial_number: 'POS-1-2-8C872406', device_type: 'pos', name: 'POS Terminal 2' },
      { serial_number: 'PRN-1-1-2E1958FE', device_type: 'printer', name: 'Receipt Printer 1' },
      { serial_number: 'PRN-1-2-CD026D2F', device_type: 'printer', name: 'Receipt Printer 2' },
      { serial_number: 'NET-1-C9AC6DB8', device_type: 'network', name: 'Network Router' },
      { serial_number: 'POS-BACKUP-1-650013F1', device_type: 'pos', name: 'Backup POS' }
    ]
  },
  {
    name: 'Niu Sushi - Bar&Delivery',
    location: 'Las Condes, Santiago',
    devices: [
      { serial_number: 'POS-2-1-FC2C4AAE', device_type: 'pos', name: 'POS Terminal 1' },
      { serial_number: 'POS-2-2-9D1787FE', device_type: 'pos', name: 'POS Terminal 2' },
      { serial_number: 'PRN-2-1-745383D3', device_type: 'printer', name: 'Receipt Printer 1' },
      { serial_number: 'PRN-2-2-F024E259', device_type: 'printer', name: 'Receipt Printer 2' },
      { serial_number: 'NET-2-A716A28B', device_type: 'network', name: 'Network Router' },
      { serial_number: 'POS-BACKUP-2-94F84FA1', device_type: 'pos', name: 'Backup POS' }
    ]
  },
  {
    name: 'Niu Sushi - Bar&Delivery',
    location: 'Ñuñoa, Santiago',
    devices: [
      { serial_number: 'POS-3-1-99941275', device_type: 'pos', name: 'POS Terminal 1' },
      { serial_number: 'POS-3-2-A9B3EF5C', device_type: 'pos', name: 'POS Terminal 2' },
      { serial_number: 'PRN-3-1-B9ED0DC7', device_type: 'printer', name: 'Receipt Printer 1' },
      { serial_number: 'PRN-3-2-03F35ED4', device_type: 'printer', name: 'Receipt Printer 2' },
      { serial_number: 'NET-3-8B74C5B0', device_type: 'network', name: 'Network Router' },
      { serial_number: 'POS-BACKUP-3-152F6F3B', device_type: 'pos', name: 'Backup POS' }
    ]
  },
  {
    name: 'Niu Sushi - Bar&Delivery',
    location: 'Valparaíso',
    devices: [
      { serial_number: 'POS-4-1-463943A1', device_type: 'pos', name: 'POS Terminal 1' },
      { serial_number: 'POS-4-2-E9615A66', device_type: 'pos', name: 'POS Terminal 2' },
      { serial_number: 'PRN-4-1-A813B54B', device_type: 'printer', name: 'Receipt Printer 1' },
      { serial_number: 'PRN-4-2-C9F2839E', device_type: 'printer', name: 'Receipt Printer 2' },
      { serial_number: 'NET-4-E42DF152', device_type: 'network', name: 'Network Router' },
      { serial_number: 'POS-BACKUP-4-81673704', device_type: 'pos', name: 'Backup POS' }
    ]
  },
  {
    name: 'Niu Sushi - Bar&Delivery',
    location: 'Viña del Mar',
    devices: [
      { serial_number: 'POS-5-1-FF7CDC88', device_type: 'pos', name: 'POS Terminal 1' },
      { serial_number: 'POS-5-2-51C495D4', device_type: 'pos', name: 'POS Terminal 2' },
      { serial_number: 'PRN-5-1-92DCA4AA', device_type: 'printer', name: 'Receipt Printer 1' },
      { serial_number: 'PRN-5-2-ADFAA12E', device_type: 'printer', name: 'Receipt Printer 2' },
      { serial_number: 'NET-5-DA331CF9', device_type: 'network', name: 'Network Router' },
      { serial_number: 'POS-BACKUP-5-D86FEBD0', device_type: 'pos', name: 'Backup POS' }
    ]
  },
  {
    name: 'Niu Sushi - Bar&Delivery',
    location: 'Concepción',
    devices: [
      { serial_number: 'POS-6-1-B7E8F9A1', device_type: 'pos', name: 'POS Terminal 1' },
      { serial_number: 'POS-6-2-C8F9A2B3', device_type: 'pos', name: 'POS Terminal 2' },
      { serial_number: 'PRN-6-1-D9A3B4C5', device_type: 'printer', name: 'Receipt Printer 1' },
      { serial_number: 'PRN-6-2-E0B4C5D6', device_type: 'printer', name: 'Receipt Printer 2' },
      { serial_number: 'NET-6-F1C5D6E7', device_type: 'network', name: 'Network Router' },
      { serial_number: 'POS-BACKUP-6-G2D6E7F8', device_type: 'pos', name: 'Backup POS' }
    ]
  },
  {
    name: 'Kao - Oriental Food',
    location: 'Las Condes, Santiago',
    devices: [
      { serial_number: 'POS-7-1-H3E7F8G9', device_type: 'pos', name: 'POS Terminal 1' },
      { serial_number: 'POS-7-2-I4F8G9H0', device_type: 'pos', name: 'POS Terminal 2' },
      { serial_number: 'PRN-7-1-J5G9H0I1', device_type: 'printer', name: 'Receipt Printer 1' },
      { serial_number: 'PRN-7-2-K6H0I1J2', device_type: 'printer', name: 'Receipt Printer 2' },
      { serial_number: 'NET-7-L7I1J2K3', device_type: 'network', name: 'Network Router' },
      { serial_number: 'POS-BACKUP-7-M8J2K3L4', device_type: 'pos', name: 'Backup POS' }
    ]
  },
  {
    name: 'Guacamole - Mexican Grill',
    location: 'Ñuñoa, Santiago',
    devices: [
      { serial_number: 'POS-8-1-N9K3L4M5', device_type: 'pos', name: 'POS Terminal 1' },
      { serial_number: 'POS-8-2-O0L4M5N6', device_type: 'pos', name: 'POS Terminal 2' },
      { serial_number: 'PRN-8-1-P1M5N6O7', device_type: 'printer', name: 'Receipt Printer 1' },
      { serial_number: 'PRN-8-2-Q2N6O7P8', device_type: 'printer', name: 'Receipt Printer 2' },
      { serial_number: 'NET-8-R3O7P8Q9', device_type: 'network', name: 'Network Router' },
      { serial_number: 'POS-BACKUP-8-S4P8Q9R0', device_type: 'pos', name: 'Backup POS' }
    ]
  }
].freeze

# Possible device statuses - using the enum keys from the Device model
DEVICE_STATUSES = %w[active warning critical].freeze

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

  # Keep track of device states to simulate changes more realistically
  device_current_states = {}
  RESTAURANTS.each do |restaurant|
    restaurant[:devices].each do |device|
      device_current_states[device[:serial_number]] = {
        restaurant_name: restaurant[:name],
        device_type: device[:device_type],
        device_name: device[:name],
        current_status: 'active', # All start as operational
        description: 'Initial operational status'
      }
    end
  end

  loop do
    # Iterate through all devices and potentially update their status
    device_current_states.each do |serial_number, data|
      current_status = data[:current_status]
      new_status = current_status

      # Simulate status changes (e.g., 10% chance to change status)
      if rand < 0.10
        possible_next_statuses = DEVICE_STATUSES - [current_status] # Don't immediately switch back to same
        if possible_next_statuses.empty?
            new_status = current_status # If only one status left, stick to it
        else
            new_status = possible_next_statuses.sample
        end

        description = case new_status
                      when 'warning' then "Device #{data[:device_name]} (#{serial_number}) is experiencing intermittent issues."
                      when 'critical' then "Device #{data[:device_name]} (#{serial_number}) is experiencing critical issues."
                      when 'active' then "Device #{data[:device_name]} (#{serial_number}) is back to operational."
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
        status: data[:current_status],
        description: data[:description],
        reported_at: Time.now.utc.iso8601 # ISO 8601 format for consistency
      }
      payload[:restaurant_name] = data[:restaurant_name] # Include restaurant data for first time creation

      send_device_status_update(payload)
    end

    sleep 5 # Send updates every 5 seconds for all devices
  end
end

# Run the simulation
run_simulation