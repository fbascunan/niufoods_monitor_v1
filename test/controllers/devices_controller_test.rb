require "test_helper"

class DevicesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @device = devices(:pos_terminal_1)
    @restaurant = @device.restaurant
  end

  test "should get show" do
    get device_path(@device)
    assert_response :success
    assert_equal @device, assigns(:device)
  end

  test "should return 404 for non-existent device" do
    get device_path(0)
    assert_response :not_found
  end

  test "should display device information correctly" do
    get device_path(@device)
    assert_response :success
    assert_select "h1", @device.name || @device.device_type.titleize
  end

  test "should display device status" do
    get device_path(@device)
    assert_response :success
    assert_select ".device-status", text: /#{@device.status}/i
  end

  test "should display device type" do
    get device_path(@device)
    assert_response :success
    assert_select ".device-type", text: /#{@device.device_type}/i
  end

  test "should display restaurant information" do
    get device_path(@device)
    assert_response :success
    assert_select ".restaurant-name", text: /#{@restaurant.name}/i
  end

  test "should display last check-in time" do
    @device.update!(last_check_in_at: Time.current)
    get device_path(@device)
    assert_response :success
    assert_select ".last-check-in"
  end

  test "should display maintenance logs" do
    maintenance_log = @device.maintenance_logs.create!(
      description: "Test maintenance",
      performed_at: Time.current,
      status: "completed"
    )
    
    get device_path(@device)
    assert_response :success
    assert_select ".maintenance-log"
  end

  test "should handle device with no maintenance logs" do
    @device.maintenance_logs.destroy_all
    get device_path(@device)
    assert_response :success
    assert_select ".maintenance-log", 0
  end

  test "should display device serial number if present" do
    @device.update!(serial_number: "SN123456")
    get device_path(@device)
    assert_response :success
    assert_select ".serial-number", text: /SN123456/
  end

  test "should display device model if present" do
    @device.update!(model: "Test Model")
    get device_path(@device)
    assert_response :success
    assert_select ".device-model", text: /Test Model/
  end

  test "should handle critical status display" do
    @device.update!(status: :critical)
    get device_path(@device)
    assert_response :success
    assert_select ".device-status.critical"
  end

  test "should handle warning status display" do
    @device.update!(status: :warning)
    get device_path(@device)
    assert_response :success
    assert_select ".device-status.warning"
  end

  test "should handle active status display" do
    @device.update!(status: :active)
    get device_path(@device)
    assert_response :success
    assert_select ".device-status.active"
  end

  test "should handle inactive status display" do
    @device.update!(status: :inactive)
    get device_path(@device)
    assert_response :success
    assert_select ".device-status.inactive"
  end
end
