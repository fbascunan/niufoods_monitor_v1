require "test_helper"

class WebsocketBroadcastJobTest < ActiveJob::TestCase
  def setup
    @restaurant = restaurants(:one)
    @device = devices(:pos_terminal_1)
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

  test "should handle restaurant with no devices" do
    empty_restaurant = Restaurant.create!(name: "Empty Restaurant")
    
    ActionCable.server.stub :broadcast, true do
      WebsocketBroadcastJob.perform_now(empty_restaurant.id, @old_status)
      
      broadcast_args = ActionCable.server.broadcast_calls.last
      data = broadcast_args[1]
      
      assert_equal 0, data[:devices].length
      assert_equal 0, data[:restaurant][:devices_count]
    end
  end

  test "should include timestamp in broadcast" do
    ActionCable.server.stub :broadcast, true do
      WebsocketBroadcastJob.perform_now(@restaurant.id, @old_status)
      
      broadcast_args = ActionCable.server.broadcast_calls.last
      data = broadcast_args[1]
      
      assert_not_nil data[:timestamp]
      assert_kind_of String, data[:timestamp]
    end
  end

  test "should handle different old status values" do
    old_statuses = ['activo', 'advertencia', 'critico', 'inactivo']
    
    old_statuses.each do |status|
      ActionCable.server.stub :broadcast, true do
        WebsocketBroadcastJob.perform_now(@restaurant.id, status)
        
        broadcast_args = ActionCable.server.broadcast_calls.last
        data = broadcast_args[1]
        
        assert_equal status, data[:restaurant][:old_status]
      end
    end
  end

  test "should include device maintenance logs count" do
    # Create some maintenance logs for the device
    @device.maintenance_logs.create!(
      description: "Test maintenance",
      performed_at: Time.current,
      status: "completed"
    )
    
    ActionCable.server.stub :broadcast, true do
      WebsocketBroadcastJob.perform_now(@restaurant.id, @old_status)
      
      broadcast_args = ActionCable.server.broadcast_calls.last
      data = broadcast_args[1]
      
      if data[:devices].any?
        device_data = data[:devices].first
        assert_not_nil device_data[:maintenance_logs_count]
      end
    end
  end

  test "should handle nil old status" do
    ActionCable.server.stub :broadcast, true do
      WebsocketBroadcastJob.perform_now(@restaurant.id, nil)
      
      broadcast_args = ActionCable.server.broadcast_calls.last
      data = broadcast_args[1]
      
      assert_nil data[:restaurant][:old_status]
    end
  end

  test "should include restaurant status change information" do
    @restaurant.update!(status: :critical)
    
    ActionCable.server.stub :broadcast, true do
      WebsocketBroadcastJob.perform_now(@restaurant.id, @old_status)
      
      broadcast_args = ActionCable.server.broadcast_calls.last
      data = broadcast_args[1]
      
      assert_equal "critico", data[:restaurant][:status]
      assert_equal "activo", data[:restaurant][:old_status]
    end
  end
end 