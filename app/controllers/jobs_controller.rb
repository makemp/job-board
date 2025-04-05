class JobsController < ApplicationController
  def index
    @jobs = Job.valid.includes(:employer)

    # Apply filters
    @jobs = @jobs.where(category: params[:category]) if params[:category].present?
    @jobs = @jobs.where(location: params[:region]) if params[:region].present?
    @jobs = @jobs.order(created_at: :desc)
    # Handle pagination
    @per_page = if params[:per_page].present? && params[:per_page] != "all"
      params[:per_page].to_i
    else
      20 # Default per page
    end

    if params[:per_page] == "all"
      # No pagination needed
      @pagy = nil
    else
      @pagy, @jobs = pagy(@jobs, items: @per_page)
    end

    # Respond to both HTML and Turbo requests
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end
end
