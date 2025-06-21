require "test_helper"

class RestaurantsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @restaurant = restaurants(:one)
  end

  test "should get index" do
    get restaurants_path
    assert_response :success
    assert_not_nil assigns(:restaurants)
  end

  test "should get show" do
    get restaurant_path(@restaurant)
    assert_response :success
    assert_equal @restaurant, assigns(:restaurant)
  end

  test "should get show with devices" do
    get restaurant_path(@restaurant)
    assert_response :success
    assert_not_nil assigns(:restaurant)
    assert_not_nil assigns(:restaurant).devices
  end

  test "should return 404 for non-existent restaurant" do
    get restaurant_path(0)
    assert_response :not_found
  end

  test "should display restaurant status correctly" do
    @restaurant.update!(status: :critical)
    get restaurant_path(@restaurant)
    assert_response :success
    assert_select ".restaurant-status", text: /critico/i
  end

  test "should display restaurant devices correctly" do
    get restaurant_path(@restaurant)
    assert_response :success
    assert_select ".device-item", @restaurant.devices.count
  end

  test "should display restaurant information" do
    get restaurant_path(@restaurant)
    assert_response :success
    assert_select "h1", @restaurant.name
  end

  test "should handle restaurant with no devices" do
    empty_restaurant = Restaurant.create!(name: "Empty Restaurant")
    get restaurant_path(empty_restaurant)
    assert_response :success
    assert_select ".device-item", 0
  end

  test "should display device status indicators" do
    get restaurant_path(@restaurant)
    assert_response :success
    @restaurant.devices.each do |device|
      assert_select ".device-status[data-status='#{device.status}']"
    end
  end

  test "should display device types correctly" do
    get restaurant_path(@restaurant)
    assert_response :success
    @restaurant.devices.each do |device|
      assert_select ".device-type", text: /#{device.device_type}/i
    end
  end

  test "should display last check-in times" do
    get restaurant_path(@restaurant)
    assert_response :success
    @restaurant.devices.each do |device|
      if device.last_check_in_at
        assert_select ".last-check-in", text: /#{device.last_check_in_at.strftime("%H:%M")}/
      end
    end
  end

  test "should handle restaurant with critical devices" do
    @restaurant.devices.first.update!(status: :critical)
    get restaurant_path(@restaurant)
    assert_response :success
    assert_select ".device-status[data-status='critico']"
  end

  test "should handle restaurant with warning devices" do
    @restaurant.devices.first.update!(status: :warning)
    get restaurant_path(@restaurant)
    assert_response :success
    assert_select ".device-status[data-status='advertencia']"
  end

  test "should handle restaurant with active devices" do
    @restaurant.devices.update_all(status: :active)
    get restaurant_path(@restaurant)
    assert_response :success
    assert_select ".device-status[data-status='activo']"
  end
end
