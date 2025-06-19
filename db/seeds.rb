# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Create restaurants with all attributes
restaurants = [
  { 
    name: "Niu Sushi - Bar&Delivery - Providencia", 
    location: "Providencia, Santiago",
    address: "Av. Providencia 1234, Providencia, Santiago",
    email: "providencia@niusushi.cl",
    phone: "+56-2-2345-6789",
    timezone: "America/Santiago",
    status: "active"
  },
  { 
    name: "Niu Sushi - Bar&Delivery - Las Condes", 
    location: "Las Condes, Santiago",
    address: "Av. Apoquindo 2345, Las Condes, Santiago",
    email: "lascondes@niusushi.cl",
    phone: "+56-2-2345-6790",
    timezone: "America/Santiago",
    status: "active"
  },
  { 
    name: "Niu Sushi - Bar&Delivery - Ñuñoa", 
    location: "Ñuñoa, Santiago",
    address: "Av. Grecia 3456, Ñuñoa, Santiago",
    email: "nunoa@niusushi.cl",
    phone: "+56-2-2345-6791",
    timezone: "America/Santiago",
    status: "active"
  },
  { 
    name: "Niu Sushi - Bar&Delivery - Valparaíso", 
    location: "Valparaíso",
    address: "Av. Argentina 4567, Valparaíso",
    email: "valparaiso@niusushi.cl",
    phone: "+56-32-2345-6792",
    timezone: "America/Santiago",
    status: "active"
  },
  { 
    name: "Niu Sushi - Bar&Delivery - Viña del Mar", 
    location: "Viña del Mar",
    address: "Av. Libertad 5678, Viña del Mar",
    email: "vinadelmar@niusushi.cl",
    phone: "+56-32-2345-6793",
    timezone: "America/Santiago",
    status: "active"
  },
  { 
    name: "Niu Sushi - Bar&Delivery - Concepción", 
    location: "Concepción",
    address: "Av. Pedro de Valdivia 6789, Concepción",
    email: "concepcion@niusushi.cl",
    phone: "+56-41-2345-6794",
    timezone: "America/Santiago",
    status: "active"
  },
  { 
    name: "Kao - Oriental Food - Las Condes", 
    location: "Las Condes, Santiago",
    address: "Av. Apoquindo 5678, Las Condes, Santiago",
    email: "contacto@kao.cl",
    phone: "+56-2-3456-7890",
    timezone: "America/Santiago",
    status: "active"
  },
  { 
    name: "Guacamole - Mexican Grill - Ñuñoa", 
    location: "Ñuñoa, Santiago",
    address: "Av. Grecia 9012, Ñuñoa, Santiago",
    email: "hola@guacamole.cl",
    phone: "+56-2-4567-8901",
    timezone: "America/Santiago",
    status: "active"
  }
]

restaurants.each do |restaurant_data|
  Restaurant.find_or_create_by!(name: restaurant_data[:name], location: restaurant_data[:location]) do |restaurant|
    restaurant.address = restaurant_data[:address]
    restaurant.email = restaurant_data[:email]
    restaurant.location = restaurant_data[:location]
    restaurant.phone = restaurant_data[:phone]
    restaurant.status = restaurant_data[:status]
    restaurant.timezone = restaurant_data[:timezone]
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
