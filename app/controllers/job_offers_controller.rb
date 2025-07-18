class JobOffersController < ApplicationController
  before_action :authenticate_employer!, except: [:show, :index, :apply_with_form, :apply_with_url, :preview,
    :apply_for_external_offer]

  before_action :check_hashcash, only: [:apply_with_form]
  def index
    @jobs = JobOffer.valid.paid.sorted.includes(:employer, :order_placement)

    # Apply filters
    @jobs = @jobs.filter_by_category(params[:category]) if params[:category].present?
    @jobs = @jobs.where(region: params[:region]) if params[:region].present?

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

    if @job_offer.expired?
      flash[:alert] = "This job offer has expired and is no longer accepting applications."
      redirect_to job_offer_path(@job_offer) and return
    end

    cv = params[:cv]
    comments = params[:comments]

    if cv.nil?
      flash[:alert] = "Please upload your CV."
      redirect_to job_offer_path(@job_offer) and return
    end

    unless cv.respond_to?(:content_type) && %w[application/pdf application/msword application/vnd.openxmlformats-officedocument.wordprocessingml.document].include?(cv.content_type)
      flash[:alert] = "Invalid CV file type. Only PDF, DOC, and DOCX are allowed."
      redirect_to job_offer_path(@job_offer) and return
    end
    if cv.size > 5.megabytes
      flash[:alert] = "CV file is too large (max 5MB)."
      redirect_to job_offer_path(@job_offer) and return
    end

    if comments.present? && comments.length > 500
      flash[:alert] = "Comments are too long (max 500 characters)."
      redirect_to job_offer_path(@job_offer) and return
    end
    @job_offer.job_offer_applications.create!(cv: cv, comments: comments).process

    flash[:notice] = "Your application has been sent to the employer."
    ahoy.track "apply_with_form", job_offer_id: @job_offer.id

    redirect_to job_offer_path(@job_offer)
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
