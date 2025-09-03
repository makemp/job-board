class JobAlertFiltersController < ApplicationController
  before_action :find_job_alert_filter, only: [:destroy, :toggle]
  before_action :verify_management_token, only: [:destroy, :toggle]

  def create
    form = JobAlertForm.add_new_filter(job_alert_filter_params)

    if form.valid?
      redirect_to manage_job_alert_path(management_token: job_alert_filter_params[:management_token]),
        notice: "Filter added successfully."
    else
      redirect_to manage_job_alert_path(management_token: job_alert_filter_params[:management_token]),
        alert: "Error adding filter: #{form.errors.full_messages.join(", ")}"
    end
  end

  def update
    form = JobAlertForm.update_existing_filter(job_alert_filter_params)

    if form.valid?
      redirect_to manage_job_alert_path(management_token: job_alert_filter_params[:management_token]),
        notice: "Filter updated successfully."
    else
      redirect_to manage_job_alert_path(management_token: job_alert_filter_params[:management_token]),
        alert: "Error updating filter: #{form.errors.full_messages.join(", ")}"
    end
  end

  def toggle
    @job_alert_filter.update!(enabled: !@job_alert_filter.enabled)

    redirect_to manage_job_alert_path(management_token: params[:management_token]),
      notice: "Filter #{@job_alert_filter.enabled? ? "enabled" : "disabled"} successfully."
  end

  def destroy
    @job_alert_filter.destroy
    redirect_to manage_job_alert_path(management_token: @job_alert_filter.job_alert.management_token),
      notice: "Filter deleted successfully."
  end

  private

  def find_job_alert_filter
    @job_alert_filter = JobAlertFilter.find(params[:id])
  end

  def verify_management_token
    @job_alert = @job_alert_filter.job_alert
    redirect_to root_path, alert: "Invalid access token." unless @job_alert.management_token == params[:management_token]
  end

  def job_alert_filter_params
    params.require(:job_alert_filter).permit(:category, :region_search, :frequency, :enabled, :management_token, :filter_id)
  end
end
