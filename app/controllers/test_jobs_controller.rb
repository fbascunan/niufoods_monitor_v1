class TestJobsController < ApplicationController
  def create
    if params[:message].present?
      TestJob.perform_later(params[:message])
    else
      TestJob.perform_later
    end
    render json: { status: "Job enqueued successfully!" }
  end
end 