class ApplicationController < ActionController::Base
  # For API controllers, skip CSRF
  protect_from_forgery with: :null_session

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActionController::ParameterMissing, with: :handle_parameter_missing
  rescue_from JSON::ParserError, with: :handle_json_error
  rescue_from ActionDispatch::Http::Parameters::ParseError, with: :handle_parse_error
  rescue_from StandardError, with: :handle_standard_error

  private

  def record_not_found
    Rails.logger.error "Record not found: #{params[:id]}"
    render json: { error: "Record not found" }, status: :not_found
  end

  def handle_parameter_missing(exception)
    render json: { 
      error: "Bad request",
      details: "Missing required parameters"
    }, status: :bad_request
  end

  def handle_json_error(exception)
    render json: { 
      error: "Bad request",
      details: "Invalid JSON format"
    }, status: :bad_request
  end

  def handle_parse_error(exception)
    render json: {
      error: "Bad request",
      details: "Malformed JSON"
    }, status: :bad_request
  end

  def handle_standard_error(exception)
    Rails.logger.error "Unexpected error: #{exception.class} - #{exception.message}"
    Rails.logger.error exception.backtrace.join("\n") if Rails.env.development?
    
    render json: {
      error: "Internal server error",
      message: "An unexpected error occurred"
    }, status: :internal_server_error
  end
end
