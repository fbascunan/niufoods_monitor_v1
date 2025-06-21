module DeviceMonitoring
  class UpdateDeviceStatus
    include ActionView::Helpers::DateHelper

    attr_reader :serial_number, :device_type, :status, :description, :last_check_in_at, :restaurant_name

    VALID_DEVICE_TYPES = %w[pos printer network].freeze

    def initialize(serial_number, device_type, status, description, last_check_in_at, restaurant_name)
      @serial_number = serial_number
      @device_type = device_type
      @status = status
      @description = description
      @last_check_in_at = last_check_in_at
      @restaurant_name = restaurant_name
    end

    def call
      Rails.logger.info "Processing device status update for device #{@serial_number} in restaurant #{@restaurant_name}"
      
      success = ApplicationRecord.transaction do
        restaurant = Restaurant.find_by(name: restaurant_name)
        
        if restaurant.nil?
          raise "Restaurant not found: #{restaurant_name}"
        end

        device = restaurant.devices.find_by(serial_number: serial_number)
        
        if device.nil?
          raise "Device not found: #{serial_number} in restaurant #{restaurant_name}"
        end

        # Validate device type and status
        validate_device_type(device)
        validate_status

        old_restaurant_status = device.restaurant.status
        
        # Update device status
        device.update!(status: @status, last_check_in_at: @last_check_in_at)
        
        # Create maintenance log with device_status and maintenance_status
        device.maintenance_logs.create!(
          description: description,
          performed_at: last_check_in_at,
          device_status: status,
          maintenance_status: "completed"
        )

        # Recalculate restaurant status
        restaurant.recalculate_status
        
        # Schedule WebSocket broadcast job with restaurant ID (5-second delay)
        # Unique jobs will prevent duplicates for the same restaurant
        WebsocketBroadcastJob.set(wait: 5.seconds).perform_later(restaurant.id, old_restaurant_status)

        Rails.logger.info "Successfully updated device #{@serial_number} status to #{@status}"
        true
      end

      success
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error "Validation error updating device #{@serial_number} status: #{e.message}"
      false
    rescue StandardError => e
      Rails.logger.error "Error updating device #{@serial_number} status: #{e.message}"
      false
    end

    private

    def validate_device_type(device)
      # Only validate if device_type is provided and different from current
      if @device_type.present? && @device_type != device.device_type
        raise "Invalid device type: #{@device_type}" unless VALID_DEVICE_TYPES.include?(@device_type)
      end
    end

    def validate_status
      # Check against enum keys (English) since simulation script sends English values
      raise "Invalid status: #{@status}" unless Device.statuses.keys.include?(@status)
    end
  end
end