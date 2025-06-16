class TestJob < ApplicationJob
  queue_as :default

  def perform(message="Hello from Sidekiq!")
    Rails.logger.info "Starting test job with message: #{message}"
    sleep 2 # Simulate some work
    Rails.logger.info "Test job completed successfully!"
  end
end 