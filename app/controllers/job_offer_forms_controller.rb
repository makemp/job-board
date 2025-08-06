class JobOfferFormsController < ApplicationController
  def new
    if params[:job_offer_form]
      @job = JobOfferForm.new(job_offer_form_params)
    elsif params[:order_placement_id]
      params_ = OrderPlacement.find(params[:order_placement_id]).job_offer_form_attributes
      @job = JobOfferForm.new(params_)
      @job.logo = params_[:logo]
    else
      @job = JobOfferForm.new(application_type: "Form")
    end
  end

  def update
    @job = JobOfferForm.new(job_offer_form_params)
    @job.valid?

    respond_to do |format|
      format.turbo_stream do
        if @job.errors.include?(:voucher_code)
          # voucher validation failed: re-render only the voucher frame
          render turbo_stream:
                   [turbo_stream.update(
                     "voucher",
                     partial: "voucher",
                     locals: {job: @job}
                   ), turbo_stream.update(
                     "submit",
                     partial: "submit",
                     locals: {job: @job}
                   )], status: :unprocessable_entity
        else
          # voucher applied successfully: update both voucher UI (to show code)
          # and the submit button (to show the new price)
          render turbo_stream: [
            turbo_stream.update(
              "voucher",
              partial: "voucher",
              locals: {job: @job}
            ),
            turbo_stream.update(
              "submit",
              partial: "submit",
              locals: {job: @job}
            ),
            turbo_stream.update(
              "voucher_applied_modal", # Target the empty frame defined in new.html.erb
              partial: "job_offer_forms/voucher_applied_modal"
              # No locals needed if the modal is static text like "Voucher Applied!"
            )
          ]
        end
      end
    end
  end

  def create
    @job = JobOfferForm.new(job_offer_form_params)
    respond_to do |format|
      if @job.valid?
        format.turbo_stream do
          render turbo_stream: turbo_stream.update(
            "new_job_offer",
            partial: "job_offer_forms/redirect",
            locals: {location: @job.submit}
          )
        end
        format.html { redirect_to @job.submit }
      else
        format.turbo_stream do
          render turbo_stream: turbo_stream.update(
            "job_form",
            partial: "form",
            locals: {job: @job}
          ), status: :unprocessable_entity
        end
      end
    end
  end

  def terms_and_conditions
  end

  def privacy
  end

  private

  def job_offer_form_params
    params.require(:job_offer_form).permit(*JobOfferForm.attribute_names).tap do |whitelisted|
      whitelisted[:voucher_code] = params[:voucher_code] if params[:voucher_code].present?
    end
  end
end
