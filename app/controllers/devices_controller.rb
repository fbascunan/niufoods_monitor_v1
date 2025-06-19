class DevicesController < ApplicationController
  def show
    @device = Device.includes(:restaurant, maintenance_logs: []).find(params[:id])
    @maintenance_logs = @device.maintenance_logs.order(performed_at: :desc).limit(50)
    
    fresh_when(@device.updated_at)
  rescue ActiveRecord::RecordNotFound
    redirect_to restaurants_path, alert: 'Device not found'
  end
end
