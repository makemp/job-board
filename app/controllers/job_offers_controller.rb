class JobOffersController < ApplicationController
  before_action :authenticate_employer!, except: [:show, :index, :apply_with_form, :apply_with_url]
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

  def show
    job_offer
  end

  def edit
    job_offer
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
    @job_offer = JobOffer.find(params[:id])
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

    JobApplicationMailer.application_email(job_offer: @job_offer,
                                           cv_original_filename: cv.original_filename,
                                           cv_read: cv.read,
                                           comments: comments).deliver_later
    flash[:notice] = "Your application has been sent to the employer."
    ahoy.track "apply_with_form", job_offer_id: @job_offer.id, step: "second"

    redirect_to job_offer_path(@job_offer)
  end

  def apply_with_url
    @job_offer = JobOffer.find(params[:id])
    ahoy.track "apply_with_url_clicked", job_offer_id: @job_offer.id, step: "second"

    redirect_to @job_offer.application_destination, allow_other_host: true, notice: "You are being redirected to the job application page."
  end

  private

  def authenticate_employer!
    raise ActiveRecord::RecordNotFound unless job_offer.employer == current_employer
  end

  def job_offer
    @job_offer ||= JobOffer.find(params[:id])
  end

  def job_offer_form_params
    params.require(:job_offer).permit(*JobOfferForm.attribute_names)
  end
end
