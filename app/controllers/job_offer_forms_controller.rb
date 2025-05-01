class JobOfferFormsController < ApplicationController
  def new
    @job = JobOfferForm.new
  end

  def update
    @job = JobOfferForm.new(job_offer_form_params)
    @job.valid?

    respond_to do |format|
      format.turbo_stream do
        puts @job.errors.inspect
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
    if @job.valid?
      redirect_to @job.submit
    else
      respond_to do |format|
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

  private

  def job_offer_form_params
    params.require(:job_offer_form).permit!
  end
end
