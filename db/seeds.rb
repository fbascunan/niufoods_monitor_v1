# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Create some restaurants with all attributes
restaurants = [
  { 
    name: "NiuSushi Downtown", 
    location: "Downtown District",
    address: "123 Main Street, Downtown",
    email: "downtown@niusushi.com",
    phone: "+1-555-0101",
    timezone: "America/New_York",
    status: "active"
  },
  { 
    name: "NiuPizza Midtown", 
    location: "Midtown District",
    address: "456 Central Ave, Midtown",
    email: "midtown@niupizza.com",
    phone: "+1-555-0102",
    timezone: "America/New_York",
    status: "active"
  },
  { 
    name: "NiuBurger Uptown", 
    location: "Uptown District",
    address: "789 Upper Street, Uptown",
    email: "uptown@niuburger.com",
    phone: "+1-555-0103",
    timezone: "America/New_York",
    status: "active"
  },
  { 
    name: "NiuSushi Westside", 
    location: "Westside District",
    address: "321 West Blvd, Westside",
    email: "westside@niusushi.com",
    phone: "+1-555-0104",
    timezone: "America/Los_Angeles",
    status: "active"
  },
  { 
    name: "NiuPizza Eastside", 
    location: "Eastside District",
    address: "654 East Road, Eastside",
    email: "eastside@niupizza.com",
    phone: "+1-555-0105",
    timezone: "America/Chicago",
    status: "active"
  }
]

restaurants.each do |restaurant_data|
  Restaurant.find_or_create_by!(name: restaurant_data[:name]) do |restaurant|
    restaurant.location = restaurant_data[:location]
    restaurant.address = restaurant_data[:address]
    restaurant.email = restaurant_data[:email]
    restaurant.phone = restaurant_data[:phone]
    restaurant.timezone = restaurant_data[:timezone]
    restaurant.status = restaurant_data[:status]
  end
end

# Create devices for each restaurant with all attributes
Restaurant.find_each do |restaurant|
  # Create POS devices
  2.times do |i|
    Device.create!(
      restaurant: restaurant,
      name: "POS Terminal #{i + 1}",
      device_type: "pos",
      status: "active",
      model: "NiuPOS Pro #{rand(1..3)}",
      serial_number: "POS-#{restaurant.id}-#{i + 1}-#{SecureRandom.hex(4).upcase}",
      last_check_in_at: Time.current - rand(0..30).minutes
    )
  end

  # Create printer devices
  2.times do |i|
    Device.create!(
      restaurant: restaurant,
      name: "Receipt Printer #{i + 1}",
      device_type: "printer",
      status: "active",
      model: "NiuPrint #{rand(1..2)}",
      serial_number: "PRN-#{restaurant.id}-#{i + 1}-#{SecureRandom.hex(4).upcase}",
      last_check_in_at: Time.current - rand(0..45).minutes
    )
  end

  # Create network devices
  Device.create!(
    restaurant: restaurant,
    name: "Network Router",
    device_type: "network",
    status: "active",
    model: "NiuNet Router",
    serial_number: "NET-#{restaurant.id}-#{SecureRandom.hex(4).upcase}",
    last_check_in_at: Time.current - rand(0..15).minutes
  )

  # Create a device with warning status for testing
  Device.create!(
    restaurant: restaurant,
    name: "Backup POS",
    device_type: "pos",
    status: "warning",
    model: "NiuPOS Backup",
    serial_number: "POS-BACKUP-#{restaurant.id}-#{SecureRandom.hex(4).upcase}",
    last_check_in_at: Time.current - 2.hours
  )
end

# Create maintenance logs with all attributes
Device.find_each do |device|
  # Create a regular maintenance log
  MaintenanceLog.create!(
    device: device,
    description: "Regular maintenance check and system update",
    performed_at: 1.day.ago,
    status: "completed"
  )

  # Create a maintenance log for devices with warning status
  if device.status == "warning"
    MaintenanceLog.create!(
      device: device,
      description: "Device showing warning signs - diagnostic check performed",
      performed_at: 6.hours.ago,
      status: "pending"
    )
  end

  # Create some historical maintenance logs
  2.times do |i|
    MaintenanceLog.create!(
      device: device,
      description: "Scheduled maintenance #{i + 1}",
      performed_at: (i + 2).days.ago,
      status: "completed"
    )
  end
end

puts "Seeds completed successfully!"
puts "Created #{Restaurant.count} restaurants"
puts "Created #{Device.count} devices"
puts "Created #{MaintenanceLog.count} maintenance logs"
