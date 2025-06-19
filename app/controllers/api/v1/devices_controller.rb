module Api
  module V1
    class DevicesController < ApplicationController
      include ActionView::Helpers::DateHelper
      
      def update_status
        # Extract serial_number from the device payload
        serial_number = params[:device][:serial_number]
        
        # Find the device by serial number
        device = Device.find_by(serial_number: serial_number)
        
        unless device
          return render json: { 
            error: "Device not found", 
            serial_number: serial_number 
          }, status: :not_found
        end

        # Extract permitted parameters from the device payload
        permitted_params = status_params
        
        # Store old restaurant status for comparison
        old_restaurant_status = device.restaurant.status
        
        # Update device attributes if provided
        device_attributes = {}
        device_attributes[:status] = permitted_params[:status] if permitted_params[:status]
        device_attributes[:name] = permitted_params[:name] if permitted_params[:name]
        device_attributes[:device_type] = permitted_params[:device_type] if permitted_params[:device_type]
        device_attributes[:last_check_in_at] = Time.current
        
        # Update device directly for immediate response
        device.update!(device_attributes)
        
        # Create maintenance log if description is provided
        if permitted_params[:description].present?
          MaintenanceLog.create!(
            device: device,
            description: permitted_params[:description],
            performed_at: Time.current,
            status: 'completed'
          )
        end
        
        # Trigger background job for additional processing
        DeviceStatusJob.perform_later(device.id, device.status, permitted_params[:description])
        
        # Recalculate restaurant status
        device.restaurant.recalculate_status
        
        # Broadcast restaurant status update via WebSocket
        broadcast_restaurant_status(device.restaurant, old_restaurant_status)
        
        render json: { 
          message: "Device status updated successfully",
          device: {
            id: device.id,
            serial_number: device.serial_number,
            name: device.name,
            status: device.status,
            restaurant: device.restaurant.name
          }
        }, status: :ok

      rescue ActiveRecord::RecordInvalid => e
        Rails.logger.error "Validation error updating device status: #{e.message}"
        render json: { 
          error: "Validation error", 
          details: e.record.errors.full_messages 
        }, status: :unprocessable_entity
      rescue StandardError => e
        Rails.logger.error "Error updating device status: #{e.message}"
        render json: { 
          error: "Internal server error",
          message: e.message
        }, status: :internal_server_error
      end

      private

      def status_params
        params.require(:device).permit(:status, :description, :name, :device_type, :serial_number)
      end
      
      def broadcast_restaurant_status(restaurant, old_status)
        return if restaurant.status == old_status
        
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
          status: status_mapping[restaurant.status] || restaurant.status,
          old_status: status_mapping[old_status] || old_status,
          devices_count: restaurant.devices.count,
          updated_ago: time_ago_in_words(restaurant.updated_at)
        })
      end
    end
  end
end