require "test_helper"

class WebsocketBroadcastJobTest < ActiveJob::TestCase
  def setup
    @restaurant = restaurants(:one)
    @device = devices(:one)
    @old_status = 'activo'
  end

  test "should broadcast restaurant and all devices status updates" do
    # Mock ActionCable broadcast
    ActionCable.server.stub :broadcast, true do
      assert_difference -> { ActionCable.server.method(:broadcast).call_count }, 1 do
        WebsocketBroadcastJob.perform_now(@restaurant.id, @old_status)
      end
    end
  end

  test "should handle restaurant not found gracefully" do
    assert_nothing_raised do
      WebsocketBroadcastJob.perform_now(999999, @old_status)
    end
  end

  test "should include correct data structure in broadcast" do
    ActionCable.server.stub :broadcast, true do
      WebsocketBroadcastJob.perform_now(@restaurant.id, @old_status)
      
      # Verify the broadcast was called with correct structure
      assert ActionCable.server.received?(:broadcast)
      broadcast_args = ActionCable.server.broadcast_calls.last
      
      assert_equal "restaurants_channel", broadcast_args[0]
      data = broadcast_args[1]
      
      assert data[:restaurant]
      assert data[:devices]
      assert data[:timestamp]
      
      # Check restaurant data
      restaurant_data = data[:restaurant]
      assert_equal @restaurant.id, restaurant_data[:id]
      assert_equal @restaurant.name, restaurant_data[:name]
      assert_equal @restaurant.location, restaurant_data[:location]
      assert restaurant_data[:status]
      assert restaurant_data[:old_status]
      assert restaurant_data[:devices_count]
      assert restaurant_data[:updated_ago]
      
      # Check devices data (array of all devices)
      devices_data = data[:devices]
      assert_kind_of Array, devices_data
      assert_equal @restaurant.devices.count, devices_data.length
      
      # Check first device data
      if devices_data.any?
        device_data = devices_data.first
        assert_equal @restaurant.id, device_data[:restaurant_id]
        assert device_data[:device_id]
        assert device_data[:name]
        assert device_data[:device_type]
        assert device_data[:status]
        assert device_data[:model]
        assert device_data[:serial_number]
        assert device_data[:last_check_in_at]
        assert device_data[:updated_ago]
      end
    end
  end

  test "should map statuses correctly" do
    ActionCable.server.stub :broadcast, true do
      WebsocketBroadcastJob.perform_now(@restaurant.id, @old_status)
      
      broadcast_args = ActionCable.server.broadcast_calls.last
      data = broadcast_args[1]
      
      # Test status mapping
      assert_equal "operational", data[:restaurant][:status] if @restaurant.status == 'activo'
      
      if data[:devices].any?
        device_data = data[:devices].first
        assert_equal "operational", device_data[:status] if device_data[:status] == 'activo'
      end
    end
  end
end 