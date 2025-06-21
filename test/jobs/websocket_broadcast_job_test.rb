require "test_helper"

class WebsocketBroadcastJobTest < ActiveJob::TestCase
  def setup
    @restaurant = restaurants(:one)
    @device = devices(:pos_terminal_1)
    @old_status = 'activo'
  end

  test "should broadcast restaurant and all devices status updates" do
    # Track if broadcast was called
    broadcast_called = false
    original_broadcast = ActionCable.server.method(:broadcast)
    
    ActionCable.server.define_singleton_method(:broadcast) do |channel, data|
      broadcast_called = true
      assert_equal "restaurants_channel", channel
      assert_kind_of Hash, data
      true
    end
    
    WebsocketBroadcastJob.perform_now(@restaurant.id, @old_status)
    assert broadcast_called, "Broadcast should have been called"
    
    # Restore original method
    ActionCable.server.define_singleton_method(:broadcast, original_broadcast)
  end

  test "should handle restaurant not found gracefully" do
    assert_nothing_raised do
      WebsocketBroadcastJob.perform_now(999999, @old_status)
    end
  end

  test "should include correct data structure in broadcast" do
    broadcast_data = nil
    original_broadcast = ActionCable.server.method(:broadcast)
    
    ActionCable.server.define_singleton_method(:broadcast) do |channel, data|
      broadcast_data = data
      true
    end
    
    WebsocketBroadcastJob.perform_now(@restaurant.id, @old_status)
    
    # Verify the broadcast was called with correct structure
    assert_not_nil broadcast_data
    assert broadcast_data[:restaurant]
    assert broadcast_data[:devices]
    assert broadcast_data[:timestamp]
    
    # Check restaurant data
    restaurant_data = broadcast_data[:restaurant]
    assert_equal @restaurant.id, restaurant_data[:id]
    assert_equal @restaurant.name, restaurant_data[:name]
    assert_equal @restaurant.location, restaurant_data[:location]
    assert restaurant_data[:status]
    assert restaurant_data[:old_status]
    assert restaurant_data[:devices_count]
    assert restaurant_data[:updated_ago]
    
    # Check devices data (array of all devices)
    devices_data = broadcast_data[:devices]
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
    
    # Restore original method
    ActionCable.server.define_singleton_method(:broadcast, original_broadcast)
  end

  test "should map statuses correctly" do
    broadcast_data = nil
    original_broadcast = ActionCable.server.method(:broadcast)
    
    ActionCable.server.define_singleton_method(:broadcast) do |channel, data|
      broadcast_data = data
      true
    end
    
    WebsocketBroadcastJob.perform_now(@restaurant.id, @old_status)
    
    # Test status mapping
    assert_equal "operational", broadcast_data[:restaurant][:status] if @restaurant.status == 'activo'
    
    if broadcast_data[:devices].any?
      device_data = broadcast_data[:devices].first
      assert_equal "operational", device_data[:status] if device_data[:status] == 'activo'
    end
    
    # Restore original method
    ActionCable.server.define_singleton_method(:broadcast, original_broadcast)
  end

  test "should handle restaurant with no devices" do
    empty_restaurant = Restaurant.create!(name: "Empty Restaurant", location: "Test Location")
    
    broadcast_data = nil
    original_broadcast = ActionCable.server.method(:broadcast)
    
    ActionCable.server.define_singleton_method(:broadcast) do |channel, data|
      broadcast_data = data
      true
    end
    
    WebsocketBroadcastJob.perform_now(empty_restaurant.id, @old_status)
    
    assert_equal 0, broadcast_data[:devices].length
    assert_equal 0, broadcast_data[:restaurant][:devices_count]
    
    # Restore original method
    ActionCable.server.define_singleton_method(:broadcast, original_broadcast)
  end

  test "should include timestamp in broadcast" do
    broadcast_data = nil
    original_broadcast = ActionCable.server.method(:broadcast)
    
    ActionCable.server.define_singleton_method(:broadcast) do |channel, data|
      broadcast_data = data
      true
    end
    
    WebsocketBroadcastJob.perform_now(@restaurant.id, @old_status)
    
    assert_not_nil broadcast_data[:timestamp]
    assert_kind_of ActiveSupport::TimeWithZone, broadcast_data[:timestamp]
    
    # Restore original method
    ActionCable.server.define_singleton_method(:broadcast, original_broadcast)
  end

  test "should handle different old status values" do
    old_statuses = ['activo', 'advertencia', 'critico', 'inactivo']
    expected_mapped_statuses = ['operational', 'warning', 'critical', 'inactive']
    original_broadcast = ActionCable.server.method(:broadcast)
    
    old_statuses.each_with_index do |status, index|
      broadcast_data = nil
      
      ActionCable.server.define_singleton_method(:broadcast) do |channel, data|
        broadcast_data = data
        true
      end
      
      WebsocketBroadcastJob.perform_now(@restaurant.id, status)
      assert_equal expected_mapped_statuses[index], broadcast_data[:restaurant][:old_status]
    end
    
    # Restore original method
    ActionCable.server.define_singleton_method(:broadcast, original_broadcast)
  end

  test "should handle nil old status" do
    broadcast_data = nil
    original_broadcast = ActionCable.server.method(:broadcast)
    
    ActionCable.server.define_singleton_method(:broadcast) do |channel, data|
      broadcast_data = data
      true
    end
    
    WebsocketBroadcastJob.perform_now(@restaurant.id, nil)
    
    # When nil is passed, it uses the current restaurant status (which gets mapped)
    expected_status = case @restaurant.status
                     when 'activo' then 'operational'
                     when 'advertencia' then 'warning'
                     when 'critico' then 'critical'
                     when 'inactivo' then 'inactive'
                     else @restaurant.status
                     end
    
    assert_equal expected_status, broadcast_data[:restaurant][:old_status]
    
    # Restore original method
    ActionCable.server.define_singleton_method(:broadcast, original_broadcast)
  end

  test "should include restaurant status change information" do
    @restaurant.update!(status: :critical)
    
    broadcast_data = nil
    original_broadcast = ActionCable.server.method(:broadcast)
    
    ActionCable.server.define_singleton_method(:broadcast) do |channel, data|
      broadcast_data = data
      true
    end
    
    WebsocketBroadcastJob.perform_now(@restaurant.id, @old_status)
    
    assert_equal "critical", broadcast_data[:restaurant][:status]
    assert_equal "operational", broadcast_data[:restaurant][:old_status]
    
    # Restore original method
    ActionCable.server.define_singleton_method(:broadcast, original_broadcast)
  end
end 