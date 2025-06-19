module DeviceMonitoring
  class UpdateDeviceStatus
    include ActionView::Helpers::DateHelper

    attr_reader :serial_number, :device_type, :status, :description, :last_check_in_at, :restaurant_name

    def initialize(serial_number, device_type, status, description, last_check_in_at, restaurant_name)
      @serial_number = serial_number
      @device_type = device_type
      @status = status
      @description = description
      @last_check_in_at = last_check_in_at
      @restaurant_name = restaurant_name
    end

    def call
      validate_device_exists
      validate_device_type
      validate_status

      # device = Device.find(@device_id)
      # device.update(status: @status, last_check_in_at: @timestamp)
      # device.maintenance_logs.create!(performed_at: @timestamp, description: "Estado actualizado a #{@status}")

      success = ApplicationRecord.transaction do
        restaurant = Restaurant.find_by(name: restaurant_name)
        device = restaurant.devices.find_by(serial_number: serial_number)

        if device.nil?
          raise "Device not found"
        end

        old_restaurant_status = device.restaurant.status
        
        device.update!(status: @status, last_check_in_at: @last_check_in_at)
        
        device.maintenance_logs.create!(
          description: description,
          performed_at: last_check_in_at,
          status: status,
        )

        restaurant.recalculate_status
        broadcast_restaurant_status(restaurant, old_restaurant_status)
        broadcast_device_status(device)

        true
      end

      success
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error("Error updating device status: #{e.message}")
      false
    rescue StandardError => e
      Rails.logger.error("Error updating device status: #{e.message}")
      false
    end

    private

    def validate_device_exists
      raise "Device not found" unless Device.exists?(serial_number: serial_number, restaurant: { name: restaurant_name })
    end

    def validate_device_type
      raise "Invalid device type" unless Device.device_types.include?(device_type)
    end

    def validate_status
      raise "Invalid status" unless Device.statuses.include?(status)
    end

    def broadcast_restaurant_status(restaurant, old_restaurant_status)
      return if restaurant.status == old_restaurant_status
      
      # Map restaurant status to CSS-friendly format
      status_mapping = {
        'activo' => 'operational',
        'advertencia' => 'warning', 
        'critico' => 'critical',
        'inactivo' => 'inactive'
      }
      
      ActionCable.server.broadcast("restaurants_channel", {
        id: restaurant.id,
        name: restaurant.name,
        location: restaurant.location,
        status: status_mapping[restaurant.status] || restaurant.status,
        old_status: status_mapping[old_restaurant_status] || old_restaurant_status,
        devices_count: restaurant.devices.count,
        updated_ago: time_ago_in_words(restaurant.updated_at)
      })
    end

    def broadcast_device_status(device)
      # Map device status to CSS-friendly format
      status_mapping = {
        'activo' => 'operational',
        'advertencia' => 'warning', 
        'critico' => 'critical',
        'inactivo' => 'inactive'
      }
      
      ActionCable.server.broadcast("restaurants_channel", {
        type: 'device_update',
        device_id: device.id,
        restaurant_id: device.restaurant.id,
        name: device.name,
        device_type: device.device_type,
        status: status_mapping[device.status] || device.status,
        model: device.model,
        serial_number: device.serial_number,
        last_check_in_at: device.last_check_in_at,
        updated_ago: time_ago_in_words(device.updated_at)
      })
    end
  end
end