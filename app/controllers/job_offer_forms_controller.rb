class JobOfferFormsController < ApplicationController
  def new
    @job = JobOfferForm.new
  end

  def create
    @job = JobOfferForm.new(job_offer_form_params)
    if @job.valid?
      redirect_to @job, notice: "Job offer was successfully created."
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.update(
            "job_form",
            partial: "form",
            locals: { job: @job }
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
