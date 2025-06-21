require "test_helper"

class RestaurantsChannelTest < ActionCable::Channel::TestCase
  def setup
    @restaurant = restaurants(:one)
  end

  test "subscribes to restaurants channel" do
    subscribe
    assert subscription.confirmed?
  end

  test "streams from restaurants channel" do
    subscribe
    assert_has_stream "restaurants_channel"
  end

  test "broadcasts status updates" do
    subscribe
    
    # Simulate a broadcast
    data = {
      restaurant: {
        id: @restaurant.id,
        name: @restaurant.name,
        status: "operational",
        old_status: "warning"
      },
      devices: [],
      timestamp: Time.current.iso8601
    }
    
    ActionCable.server.broadcast("restaurants_channel", data)
    
    # Verify the message was received
    assert_broadcast_on("restaurants_channel", data)
  end

  test "handles multiple subscribers" do
    # Subscribe first user
    subscribe
    assert subscription.confirmed?
    
    # Subscribe second user
    subscribe
    assert subscription.confirmed?
  end

  test "unsubscribes correctly" do
    subscribe
    assert subscription.confirmed?
    
    unsubscribe
    assert_empty subscription.streams
  end

  test "broadcasts to correct channel" do
    subscribe
    
    # Verify we're subscribed to the correct channel
    assert_equal "restaurants_channel", subscription.streams.first
  end

  test "handles connection without parameters" do
    subscribe
    assert subscription.confirmed?
  end

  test "receives restaurant data updates" do
    subscribe
    
    # Simulate restaurant data update
    restaurant_data = {
      restaurant: {
        id: @restaurant.id,
        name: @restaurant.name,
        location: @restaurant.location,
        status: "operational",
        devices_count: @restaurant.devices.count,
        updated_ago: "2 minutes ago"
      },
      devices: @restaurant.devices.map do |device|
        {
          device_id: device.id,
          restaurant_id: @restaurant.id,
          name: device.name,
          device_type: device.device_type,
          status: device.status,
          model: device.model,
          serial_number: device.serial_number,
          last_check_in_at: device.last_check_in_at,
          updated_ago: "1 minute ago"
        }
      end,
      timestamp: Time.current
    }
    
    ActionCable.server.broadcast("restaurants_channel", restaurant_data)
    assert_broadcast_on("restaurants_channel", restaurant_data)
  end

  test "handles device status updates" do
    subscribe
    
    # Simulate device status update
    device_update = {
      restaurant: {
        id: @restaurant.id,
        name: @restaurant.name,
        status: "warning",
        old_status: "operational"
      },
      devices: [
        {
          device_id: @restaurant.devices.first.id,
          restaurant_id: @restaurant.id,
          name: @restaurant.devices.first.name,
          device_type: @restaurant.devices.first.device_type,
          status: "warning",
          model: @restaurant.devices.first.model,
          serial_number: @restaurant.devices.first.serial_number,
          last_check_in_at: Time.current,
          updated_ago: "just now"
        }
      ],
      timestamp: Time.current
    }
    
    ActionCable.server.broadcast("restaurants_channel", device_update)
    assert_broadcast_on("restaurants_channel", device_update)
  end
end
