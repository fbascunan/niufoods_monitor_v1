class ApplicationController < ActionController::Base
  # For API controllers, skip CSRF
  protect_from_forgery with: :null_session

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  private

  def record_not_found
    Rails.logger.error "Record not found: #{params[:id]}"
    render json: { error: "Record not found" }, status: :not_found
  end
end
