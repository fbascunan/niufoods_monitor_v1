module Api
  module V1
    class DevicesController < ApplicationController
      def update
        device = Device.find(params[:id])
        permitted_params = status_params
        DeviceStatusJob.perform_later(device.id, permitted_params[:status])
        render json: { message: "Device status updated" }, status: :ok

        rescue ActiveRecord::RecordNotFound
          render json: { error: "Device not found" }, status: :not_found
        rescue StandardError => e
          Rails.logger.error "Error updating device status: #{e.message}"
          render json: { error: "Internal server error" }, status: :internal_server_error
      end

      private

      def status_params
        params.require(:device).permit(:status)
      end
    end
  end
end