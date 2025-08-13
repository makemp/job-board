class JobOffersController < ApplicationController
  include AntiBot
  MAX_PER_PAGE = 50
  before_action :authenticate_employer!, except: [:show, :index, :apply_with_form, :apply_with_url, :preview,
    :apply_for_external_offer]

  def index
    @jobs = JobOffer.valid.paid.sorted.includes(:employer, :order_placement)

    # Apply filters
    @jobs = @jobs.filter_by_category(params[:category]) if params[:category].present?
    @jobs = @jobs.where(region: params[:region]) if params[:region].present?

    # Handle pagination
    @per_page = if params[:per_page].present?
      per_page_ = params[:per_page].to_i
      (per_page_ > MAX_PER_PAGE) ? MAX_PER_PAGE : per_page_
    else
      20 # Default per page
    end

    # Ensure page parameter is valid
    page_param = params[:page].present? ? params[:page].to_i : 1
    @pagy, @jobs = pagy(@jobs, limit: @per_page, page: page_param)
    # raise @pagy.inspect

    # Respond to both HTML and Turbo requests
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def show
    job_offer
  end

  def preview
    job_offer
    render layout: false
  end

  def edit
    job_offer

    if job_offer.expired?
      flash[:alert] = "This job offer has expired and cannot be edited."
      redirect_to job_offer_path(job_offer) and return
    end

    @job = JobOfferForm.from_job_offer(job_offer)
  end

  def destroy
    job_offer.expire_manually!
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace("job_offer_#{job_offer.id}", partial: "employers/dashboard/job_offer", locals: {job_offer: job_offer})
      end
      format.html { redirect_to job_offers_path, notice: "Job offer expired successfully." }
    end
  end

  def update
    if job_offer.expired?
      flash[:alert] = "This job offer has expired and cannot be updated."
      redirect_to job_offer_path(job_offer) and return
    end

    @job = JobOfferForm.new(job_offer_form_params.merge(email: current_employer.email))

    if @job.valid? && job_offer.update!(job_offer_form_params)
      redirect_to job_offer_path(job_offer, success: true), notice: "Job offer updated successfully."
    else
      flash[:alert] = @job.errors.full_messages.to_sentence
      redirect_to edit_job_offer_path(job_offer)
    end
  end

  # POST /job_offers/:id/apply_with_form
  def apply_with_form
    @job_offer = JobOffer.find_by_slug(params[:id])

    unless valid_anti_bot_token?
      render turbo_stream: turbo_stream.update("job_offer_form_error-#{@job_offer.slug}"),
        partial: "shared/error_message",
        locals: {message: "Security validation failed. Please try again.", job_offer: @job_offer}
      return
    end

    if @job_offer.expired?
      render turbo_stream: turbo_stream.replace("job_offer_form-#{@job_offer.slug}"),
        partial: "shared/error_message",
        locals: {message: "This job offer has expired and is no longer accepting applications.", job_offer: @job_offer}
      return
    end

    cv = params[:cv]
    comments = params[:comments]

    unless params[:terms_and_conditions] == "1"
      render turbo_stream: turbo_stream.update("job_offer_form_error-#{@job_offer.slug}"),
        partial: "shared/error_message",
        locals: {message: "You must accept the terms and conditions to apply.", job_offer: @job_offer}
      return
    end

    if cv.nil?
      render turbo_stream: turbo_stream.update("job_offer_form_error-#{@job_offer.slug}"),
        partial: "shared/error_message",
        locals: {message: "Please upload your CV.", job_offer: @job_offer}
      return
    end

    unless cv.respond_to?(:content_type) && %w[application/pdf application/msword application/vnd.openxmlformats-officedocument.wordprocessingml.document].include?(cv.content_type)
      render turbo_stream: turbo_stream.update("job_offer_form_error-#{@job_offer.slug}"),
        partial: "shared/error_message",
        locals: {message: "Invalid CV file type. Only PDF, DOC, and DOCX are allowed.", job_offer: @job_offer}
      return
    end

    if cv.size > 5.megabytes
      render turbo_stream: turbo_stream.update("job_offer_form_error-#{@job_offer.slug}",
        partial: "shared/error_message",
        locals: {message: "CV file is too large (max 5MB).", job_offer: @job_offer})
      return
    end

    if comments.present? && comments.length > 5000
      render turbo_stream: turbo_stream.update("job_offer_form_error-#{@job_offer.slug}",
        partial: "shared/error_message",
        locals: {message: "Comments are too long (max 5000 characters).", job_offer: @job_offer})
      return
    end

    @job_offer.job_offer_applications.create!(cv: cv, comments: comments).process

    ahoy.track "apply_with_form", job_offer_id: @job_offer.id

    render turbo_stream: turbo_stream.replace("job_offer_form-#{@job_offer.slug}",
      partial: "application_sent",
      locals: {message: "Your application has been sent to the employer!", job_offer: @job_offer})
  rescue ActiveRecord::RecordInvalid => e
    if e.message.include?("virus")
      Rails.logger.warn("Virus detected in CV upload: #{e.message}")
      render turbo_stream: turbo_stream.replace("job_offer_form-#{@job_offer.slug}",
        partial: "shared/error_message",
        locals: {message: "Virus detected", job_offer: @job_offer}) and return
    else
      raise e
    end
  end

  def apply_with_url
    @job_offer = JobOffer.find_by_slug(params[:id])

    if @job_offer.expired?
      flash[:alert] = "This job offer has expired and is no longer accepting applications."
      redirect_to job_offer_path(@job_offer) and return
    end

    ahoy.track "apply_with_url_clicked", job_offer_id: @job_offer.id

    redirect_to @job_offer.application_destination, allow_other_host: true
  end

  def apply_for_external_offer
    @job_offer = ExternalJobOffer.find_by_slug(params[:id])
    ahoy.track "apply_external_job_offer", job_offer_id: @job_offer.id

    redirect_to @job_offer.application_destination, allow_other_host: true
  end

  private

  def anti_bot_params
    @anti_bot_params ||= params.slice(*AntiBot::FIELDS)
  end

  def authenticate_employer!
    raise ActiveRecord::RecordNotFound unless job_offer.employer == current_employer
  end

  def job_offer
    @job_offer ||= JobOffer.find_by_slug(params[:id])
  end

  def job_offer_form_params
    params.require(:job_offer).permit(*JobOfferForm.attribute_names)
  end
end
