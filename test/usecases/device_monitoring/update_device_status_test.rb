require "test_helper"

class UpdateDeviceStatusTest < ActiveSupport::TestCase
    def setup
    @restaurant = restaurants(:one)
    @device = devices(:one)
    @serial_number = @device.serial_number
    @device_type = @device.device_type
    @status = "activo"
    @description = "Test status update"
    @last_check_in_at = Time.current
    @restaurant_name = @restaurant.name
    
    @usecase = DeviceMonitoring::UpdateDeviceStatus.new(
        @serial_number,
        @device_type,
        @status,
        @description,
        @last_check_in_at,
        @restaurant_name
    )
    end

    test "updates device status and creates maintenance log" do
    old_restaurant_status = @restaurant.status
    
    assert_enqueued_with(job: WebsocketBroadcastJob, wait: 5.seconds) do
        @usecase.call
    end

    @device.reload
    assert_equal @status, @device.status
    assert_equal @last_check_in_at, @device.last_check_in_at
    
    maintenance_log = @device.maintenance_logs.last
    assert_equal @last_check_in_at, maintenance_log.performed_at
    assert_equal @description, maintenance_log.description
    assert_equal @status, maintenance_log.status
    end

    test "schedules websocket broadcast job with restaurant ID" do
    old_restaurant_status = @restaurant.status
    
    assert_enqueued_with(job: WebsocketBroadcastJob, wait: 5.seconds) do
        @usecase.call
    end
    
    # Check that the job was enqueued with restaurant ID
    assert_enqueued_jobs 1, only: WebsocketBroadcastJob
    enqueued_job = ActiveJob::Base.queue_adapter.enqueued_jobs.last
    assert_equal @restaurant.id, enqueued_job[:args][0]
    assert_equal old_restaurant_status, enqueued_job[:args][1]
    end

    test "recalculates restaurant status" do
    @usecase.call
    
    @restaurant.reload
    # The restaurant status should be recalculated based on device statuses
    assert_not_nil @restaurant.status
    end

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
end