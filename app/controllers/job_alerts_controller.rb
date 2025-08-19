class JobAlertsController < ApplicationController
  def index
    # Since there's no user authentication, redirect to root or show empty state
    @job_alerts = JobAlert.none
    redirect_to root_path, notice: "Job alerts require account creation (coming soon)"
  end

  def show
  end

  def new
    @alert_form = JobAlertForm.new
    @alert_form.category = params[:category] if params[:category].present?
    @alert_form.region = params[:region] if params[:region].present?
  end

  def create
    alert_form = JobAlertForm.create(job_alert_params)

    if alert_form.errors.present?
      render turbo_stream: turbo_stream.replace("job-alert-form", partial: "job_alerts/form", locals: {
        alert_form:
      })
    else
      render turbo_stream: [
        turbo_stream.replace("job-alert-form", partial: "job_alerts/confirmation_sent", locals: {alert_form:})
      ]
    end
  end

  def confirm
  end

  def manage
    @job_alert = JobAlert.find_by(management_token: params[:token])
  end

  def update_via_token
  end

  def unsubscribe
  end

  def edit
  end

  def update
  end

  def destroy
  end

  private

  def job_alert_params
    params.expect(job_alert_form: [:email, alert_form: [:category, :region, :name, :frequency, :region_search]])
  end
end
