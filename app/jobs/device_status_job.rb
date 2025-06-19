class DeviceStatusJob < ApplicationJob
  queue_as :default

  def perform(device_id, status, description = nil)
    Rails.logger.info "Processing device status update for device #{device_id}"
    
    begin
      device = Device.find(device_id)
      
      # Update device status
      device.update!(status: status, last_check_in_at: Time.current)
      
      # Create maintenance log if description provided
      if description.present?
        MaintenanceLog.create!(
          device: device,
          description: description,
          performed_at: Time.current,
          status: 'completed'
        )
      end
      
      # Recalculate restaurant status
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
