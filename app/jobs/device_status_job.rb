class DeviceStatusJob < ApplicationJob
  queue_as :default

  def perform(device_id, status, timestamp = Time.current)
    Rails.logger.info "Processing device status update for device #{device_id}"
    
    begin
      DeviceMonitoring::UpdateDeviceStatus.new(device_id, status, timestamp).call
      device.restaurant.recalculate_status
      Rails.logger.info "Successfully updated device #{device_id} status to #{status}"
    rescue ActiveRecord::RecordNotFound => e
      Rails.logger.error "Device #{device_id} not found: #{e.message}"
      raise
    rescue StandardError => e
      Rails.logger.error "Error updating device #{device_id} status: #{e.message}"
      raise
    end
  end
end
