module DeviceMonitoring
  class UpdateDeviceStatus
    def initialize(device_id, status, timestamp)
      @device_id = device_id
      @status = status
      @timestamp = timestamp
    end

    def call
      device = Device.find(@device_id)
      device.update(status: @status, last_check_in_at: @timestamp)
      device.maintenance_logs.create!(performed_at: @timestamp, description: "Estado actualizado a #{@status}")
    end
  end
end