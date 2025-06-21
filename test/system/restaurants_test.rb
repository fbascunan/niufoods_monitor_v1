require "application_system_test_case"

class RestaurantsTest < ApplicationSystemTestCase
  def setup
    @restaurant = restaurants(:one)
    @device = devices(:pos_terminal_1)
  end

  test "visiting the restaurants index" do
    visit restaurants_path
    assert_selector "h1", text: "Restaurants"
    assert_selector ".restaurant-item", count: Restaurant.count
  end

  test "viewing restaurant details" do
    visit restaurant_path(@restaurant)
    assert_selector "h1", text: @restaurant.name
    assert_selector ".device-item", count: @restaurant.devices.count
  end

  test "displaying restaurant status indicators" do
    @restaurant.update!(status: :critical)
    visit restaurant_path(@restaurant)
    assert_selector ".restaurant-status.critical"
  end

  test "displaying device status indicators" do
    @device.update!(status: :warning)
    visit restaurant_path(@restaurant)
    assert_selector ".device-status.warning"
  end

  test "navigating between restaurants" do
    visit restaurant_path(@restaurant)
    assert_selector "h1", text: @restaurant.name
    
    other_restaurant = restaurants(:two)
    visit restaurant_path(other_restaurant)
    assert_selector "h1", text: other_restaurant.name
  end

  test "viewing device details" do
    visit device_path(@device)
    assert_selector "h1"
    assert_selector ".device-status"
    assert_selector ".device-type"
  end

  test "displaying maintenance logs" do
    maintenance_log = @device.maintenance_logs.create!(
      description: "System test maintenance",
      performed_at: Time.current,
      status: "completed"
    )
    
    visit device_path(@device)
    assert_selector ".maintenance-log"
    assert_text "System test maintenance"
  end

  test "handling restaurant with no devices" do
    empty_restaurant = Restaurant.create!(name: "Empty Restaurant")
    visit restaurant_path(empty_restaurant)
    assert_selector "h1", text: "Empty Restaurant"
    assert_selector ".device-item", count: 0
  end

  test "displaying device information correctly" do
    @device.update!(
      name: "Test POS Terminal",
      model: "POS-2000",
      serial_number: "SN123456"
    )
    
    visit device_path(@device)
    assert_text "Test POS Terminal"
    assert_text "POS-2000"
    assert_text "SN123456"
  end

  test "displaying last check-in time" do
    @device.update!(last_check_in_at: Time.current)
    visit device_path(@device)
    assert_selector ".last-check-in"
  end

  test "handling different device statuses" do
    statuses = [:active, :warning, :critical, :inactive]
    
    statuses.each do |status|
      @device.update!(status: status)
      visit device_path(@device)
      assert_selector ".device-status.#{status}"
    end
  end

  test "responsive design elements" do
    visit restaurants_path
    assert_selector ".restaurant-grid"
    
    visit restaurant_path(@restaurant)
    assert_selector ".device-grid"
  end

  test "breadcrumb navigation" do
    visit device_path(@device)
    assert_selector ".breadcrumb"
    assert_text @restaurant.name
  end

  test "status color coding" do
    # Test critical status (should be red)
    @device.update!(status: :critical)
    visit device_path(@device)
    assert_selector ".device-status.critical"
    
    # Test warning status (should be yellow/orange)
    @device.update!(status: :warning)
    visit device_path(@device)
    assert_selector ".device-status.warning"
    
    # Test active status (should be green)
    @device.update!(status: :active)
    visit device_path(@device)
    assert_selector ".device-status.active"
  end

  test "real-time status updates" do
    visit restaurant_path(@restaurant)
    initial_status = @device.status
    
    # Simulate status change
    @device.update!(status: :critical)
    
    # In a real application with WebSocket, this would update automatically
    # For now, we just verify the page can handle different statuses
    visit restaurant_path(@restaurant)
    assert_selector ".device-status.critical"
  end

  test "device type filtering" do
    visit restaurant_path(@restaurant)
    
    # Should display all device types
    assert_selector ".device-type", text: /pos/i
    assert_selector ".device-type", text: /printer/i
    assert_selector ".device-type", text: /network/i
  end

  test "maintenance log display" do
    # Create multiple maintenance logs
    3.times do |i|
      @device.maintenance_logs.create!(
        description: "Maintenance #{i + 1}",
        performed_at: Time.current - i.hours,
        status: "completed"
      )
    end
    
    visit device_path(@device)
    assert_selector ".maintenance-log", count: 3
  end

  test "error handling for non-existent resources" do
    visit restaurant_path(999999)
    assert_text "not found" or assert_text "404"
    
    visit device_path(999999)
    assert_text "not found" or assert_text "404"
  end
end 