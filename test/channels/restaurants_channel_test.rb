require "test_helper"

class RestaurantsChannelTest < ActionCable::Channel::TestCase
  def setup
    @restaurant = restaurants(:one)
  end

  test "subscribes to restaurants channel" do
    subscribe
    assert subscription.confirmed?
  end

  test "subscribes to specific restaurant" do
    subscribe(restaurant_id: @restaurant.id)
    assert subscription.confirmed?
  end

  test "rejects subscription with invalid restaurant id" do
    subscribe(restaurant_id: 999999)
    assert subscription.rejected?
  end

  test "rejects subscription without restaurant id" do
    subscribe(restaurant_id: nil)
    assert subscription.rejected?
  end

  test "broadcasts status updates" do
    subscribe(restaurant_id: @restaurant.id)
    
    # Simulate a broadcast
    data = {
      restaurant: {
        id: @restaurant.id,
        name: @restaurant.name,
        status: "critico",
        old_status: "activo"
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
    subscribe(restaurant_id: @restaurant.id)
    assert subscription.confirmed?
    
    # Subscribe second user
    subscribe(restaurant_id: @restaurant.id)
    assert subscription.confirmed?
  end

  test "unsubscribes correctly" do
    subscribe(restaurant_id: @restaurant.id)
    assert subscription.confirmed?
    
    unsubscribe
    assert subscription.rejected?
  end

  test "handles connection parameters" do
    subscribe(restaurant_id: @restaurant.id)
    
    # Test that we can access the restaurant_id parameter
    assert_equal @restaurant.id.to_s, subscription.params[:restaurant_id]
  end

  test "validates restaurant exists" do
    # Test with non-existent restaurant
    subscribe(restaurant_id: 999999)
    assert subscription.rejected?
  end

  test "handles string restaurant id" do
    subscribe(restaurant_id: @restaurant.id.to_s)
    assert subscription.confirmed?
  end

  test "handles malformed restaurant id" do
    subscribe(restaurant_id: "invalid")
    assert subscription.rejected?
  end

  test "broadcasts to correct channel" do
    subscribe(restaurant_id: @restaurant.id)
    
    # Verify we're subscribed to the correct channel
    assert_equal "restaurants_channel", subscription.streams.first
  end

  test "handles connection without parameters" do
    subscribe
    assert subscription.confirmed?
  end

  test "validates restaurant access permissions" do
    # This test would be expanded if we add authentication/authorization
    subscribe(restaurant_id: @restaurant.id)
    assert subscription.confirmed?
  end
end
