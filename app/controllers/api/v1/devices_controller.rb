module Api
  module V1
    class DevicesController < ApplicationController
      include ActionView::Helpers::DateHelper
      
      def update_status
        serial_number = params[:device][:serial_number]        
        device = Device.find_by(serial_number: serial_number)
        
        unless device
          return render json: { 
            error: "Device not found", 
            serial_number: serial_number 
          }, status: :not_found
        end

        permitted_params = status_params

        # Use the orchestrator use case to handle the entire flow
        use_case = DeviceMonitoring::UpdateDeviceStatus.new(
          serial_number,
          permitted_params[:device_type] || device.device_type,
          permitted_params[:status],
          permitted_params[:description],
          Time.current,
          device.restaurant.name
        )

        if use_case.call
          render json: { 
            message: "Device status updated successfully. WebSocket update will be broadcast in 5 seconds.",
            device: {
              id: device.id,
              serial_number: device.serial_number,
              name: device.name,
              status: device.status,
              restaurant: device.restaurant.name
            }
          }, status: :ok
        else
          render json: { 
            error: "Failed to update device status"
          }, status: :unprocessable_entity
        end

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
    end
  end
end