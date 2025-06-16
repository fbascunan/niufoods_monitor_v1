require "test_helper"

class UpdateDeviceStatusTest < ActiveSupport::TestCase
    def setup
    @device = Device.create!(
        device_type: "test",
        restaurant: restaurants(:one),
        status: "active"
    )
    @status = "active"
    @timestamp = Time.current.round(6) # 6 decimal places for precision ( includes microseconds) default is 9 (nanoseconds)
    @usecase = DeviceMonitoring::UpdateDeviceStatus.new(@device.id, @status, @timestamp)
    end

    test "updates device status and creates maintenance log" do
    @usecase.call

    @device.reload
    assert_equal @status, @device.status
    assert_equal @timestamp, @device.last_check_in_at
    
    maintenance_log = @device.maintenance_logs.last
    assert_equal @timestamp, maintenance_log.performed_at
    assert_equal "Estado actualizado a #{@status}", maintenance_log.description
    end
end