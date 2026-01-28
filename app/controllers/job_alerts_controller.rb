class JobAlertsController < ApplicationController
  include AntiBot

  def index
    # Since there's no user authentication, redirect to root or show empty state
    @job_alerts = JobAlert.none
    redirect_to root_path, notice: "Job alerts created. Required confirmation."
  end

  def show
  end

  def new
    @job_alert_form = JobAlertForm.new
    @job_alert_form.category = params[:category] if params[:category].present?
    @job_alert_form.region = params[:region] if params[:region].present?
  end

  def create
    unless valid_anti_bot_token?
      render turbo_stream: turbo_stream.replace("job-alert-form", partial: "job_alerts/form", locals: {
        alert_form: @job_alert_form
      })
      return
    end

    @job_alert_form = JobAlertForm.create(job_alert_params)

    if @job_alert_form.errors.present?
      render turbo_stream: turbo_stream.replace("job-alert-form", partial: "job_alerts/form", locals: {
        alert_form: @job_alert_form
      })
    else
      render turbo_stream: [
        turbo_stream.replace("job-alert-form", partial: "job_alerts/confirmation_sent", locals: {alert_form: @job_alert_form})
      ]
    end
  end

  def confirm
    JobAlert.transaction do
      JobAlertFilter.transaction do
        @job_alert_filter = JobAlertFilter.find_by(confirmation_token: params[:id])
        head :not_found and return if @job_alert_filter.nil?
        @job_alert_filter.update!(confirmed_at: Time.current, enabled: true)
        @job_alert_filter.job_alert.update!(confirmed_at: Time.current)
        management_token = @job_alert_filter.job_alert.management_token
        redirect_to manage_job_alert_path(management_token: management_token)
      end
    end
  end

  def manage
    @job_alert = JobAlert.find_by(management_token: params[:management_token])
    head :not_found and return if @job_alert.nil?
    redirect_to confirm_job_alert_path(id: params[:management_token]) unless @job_alert.active?
  end

  def update_via_token
  end

  def unsubscribe
    @job_alert = JobAlert.find_by(management_token: params[:management_token])
    head :not_found and return if @job_alert.nil?

    @job_alert.destroy!

    flash[:notice] = "You have successfully unsubscribed from job alerts."
    redirect_to root_path
  end

  def edit
  end

  def update
  end

  def destroy
  end

  private

  def anti_bot_params
    params["job_alert_form"].slice(*AntiBot::FIELDS)
  end

  def job_alert_params
    params.expect(job_alert_form: [:email, alert_form: [:category, :region, :name, :frequency, :region_search]])
  end
end
