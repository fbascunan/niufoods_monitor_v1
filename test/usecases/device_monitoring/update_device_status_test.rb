require "test_helper"
require "sidekiq"
require "active_job/test_helper"

class UpdateDeviceStatusTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  def setup
    @restaurant = restaurants(:one)
    @device = devices(:pos_terminal_1)
    @serial_number = @device.serial_number
    @device_type = @device.device_type
    @status = "active"
    @description = "Test status update"
    @last_check_in_at = Time.current
    @restaurant_name = @restaurant.name
    clear_enqueued_jobs
    @usecase = DeviceMonitoring::UpdateDeviceStatus.new(
      @serial_number,
      @device_type,
      @status,
      @description,
      @last_check_in_at,
      @restaurant_name
    )
  end

  def teardown
    clear_enqueued_jobs
  end

  # Integration: device status update triggers maintenance log, restaurant status, websocket job
  test "updates device status and creates maintenance log" do
    old_restaurant_status = @restaurant.status
    assert_enqueued_with(job: WebsocketBroadcastJob, args: [@restaurant.id, old_restaurant_status]) do
      @usecase.call
    end
    @device.reload
    assert_equal @status, @device.status
    assert_equal @last_check_in_at.to_i, @device.last_check_in_at.to_i
    maintenance_log = @device.maintenance_logs.last
    assert_equal @last_check_in_at.to_i, maintenance_log.performed_at.to_i
    assert_equal @description, maintenance_log.description
    assert_equal @status, maintenance_log.device_status
  end

  test "schedules websocket broadcast job with restaurant ID" do
    old_restaurant_status = @restaurant.status
    assert_enqueued_with(job: WebsocketBroadcastJob, args: [@restaurant.id, old_restaurant_status]) do
      @usecase.call
    end
    assert_enqueued_jobs 1, only: WebsocketBroadcastJob
    enqueued_job = enqueued_jobs.last
    assert_equal @restaurant.id, enqueued_job[:args][0]
    assert_equal old_restaurant_status, enqueued_job[:args][1]
  end

  test "recalculates restaurant status" do
    @usecase.call
    @restaurant.reload
    assert_not_nil @restaurant.status
  end

  # Integration: error handling for missing/invalid device, restaurant, status, or type
  test "returns false when device not found" do
    usecase = DeviceMonitoring::UpdateDeviceStatus.new(
      "invalid_serial",
      @device_type,
      @status,
      @description,
      @last_check_in_at,
      @restaurant_name
    )
    assert_not usecase.call
  end

  test "returns false when invalid status" do
    usecase = DeviceMonitoring::UpdateDeviceStatus.new(
      @serial_number,
      @device_type,
      "invalid_status",
      @description,
      @last_check_in_at,
      @restaurant_name
    )
    assert_not usecase.call
  end

  test "returns false when invalid device type" do
    usecase = DeviceMonitoring::UpdateDeviceStatus.new(
      @serial_number,
      "invalid_type",
      @status,
      @description,
      @last_check_in_at,
      @restaurant_name
    )
    assert_not usecase.call
  end

  test "returns false when restaurant not found" do
    usecase = DeviceMonitoring::UpdateDeviceStatus.new(
      @serial_number,
      @device_type,
      @status,
      @description,
      @last_check_in_at,
      "Invalid Restaurant"
    )
    assert_not usecase.call
  end

  # Integration: status propagation for all valid statuses
  test "handles warning status correctly" do
    usecase = DeviceMonitoring::UpdateDeviceStatus.new(
      @serial_number,
      @device_type,
      "warning",
      @description,
      @last_check_in_at,
      @restaurant_name
    )
    assert usecase.call
    @device.reload
    assert_equal "warning", @device.status
  end

  test "handles critical status correctly" do
    usecase = DeviceMonitoring::UpdateDeviceStatus.new(
      @serial_number,
      @device_type,
      "critical",
      @description,
      @last_check_in_at,
      @restaurant_name
    )
    assert usecase.call
    @device.reload
    assert_equal "critical", @device.status
  end

  test "handles inactive status correctly" do
    usecase = DeviceMonitoring::UpdateDeviceStatus.new(
      @serial_number,
      @device_type,
      "inactive",
      @description,
      @last_check_in_at,
      @restaurant_name
    )
    assert usecase.call
    @device.reload
    assert_equal "inactive", @device.status
  end

  # Maintenance log attributes integration
  test "creates maintenance log with correct attributes" do
    @usecase.call
    maintenance_log = @device.maintenance_logs.last
    assert_not_nil maintenance_log
    assert_equal @description, maintenance_log.description
    assert_equal @last_check_in_at.to_i, maintenance_log.performed_at.to_i
    assert_equal @status, maintenance_log.device_status
  end

  # Timestamp update integration
  test "updates last_check_in_at timestamp" do
    old_check_in = @device.last_check_in_at
    @usecase.call
    @device.reload
    assert_not_equal old_check_in.to_i, @device.last_check_in_at.to_i
    assert_equal @last_check_in_at.to_i, @device.last_check_in_at.to_i
  end
end