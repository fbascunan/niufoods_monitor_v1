# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Create some restaurants
restaurants = [
  { name: "NiuSushi" },
  { name: "NiuPizza" },
  { name: "NiuBurger" }
]

restaurants.each do |restaurant_data|
  Restaurant.find_or_create_by!(restaurant_data)
end

# Create devices for each restaurant
Restaurant.find_each do |restaurant|
  # Create POS devices
  2.times do |i|
    Device.create!(
      restaurant: restaurant,
      device_type: "pos",
      status: "active",
      last_check_in_at: Time.current
    )
  end

  # Create printer devices
  2.times do |i|
    Device.create!(
      restaurant: restaurant,
      device_type: "printer",
      status: "active",
      last_check_in_at: Time.current
    )
  end

  # Create network devices
  Device.create!(
    restaurant: restaurant,
    device_type: "network",
    status: "active",
    last_check_in_at: Time.current
  )
end

# Create some maintenance logs
Device.find_each do |device|
  MaintenanceLog.create!(
    device: device,
    performed_at: 1.day.ago,
    description: "Regular maintenance check"
  )
end
