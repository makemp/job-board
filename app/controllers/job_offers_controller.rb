class JobOffersController < ApplicationController
  def index
    @jobs = JobOffer.valid.includes(:employer)

    # Apply filters
    @jobs = @jobs.where(category: params[:category]) if params[:category].present?
    @jobs = @jobs.where(location: params[:region]) if params[:region].present?
    @jobs = @jobs.order(created_at: :desc)

    # Handle pagination
    @per_page = if params[:per_page].present?
      (params[:per_page] == "all") ? nil : params[:per_page].to_i
    else
      20 # Default per page
    end

    if @per_page.nil?
      # Show all results
      @pagy = nil
    else
      # Ensure page parameter is valid
      page_param = params[:page].present? ? params[:page].to_i : 1
      @pagy, @jobs = pagy(@jobs, limit: @per_page, page: page_param)
      # raise @pagy.inspect
    end

    # Respond to both HTML and Turbo requests
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  private

  def job_params
    params.require(:job).expect(:title, :description, :category, :location)
    # Note: we don't include :email in job_params as it's used for employer creation
  end
end
