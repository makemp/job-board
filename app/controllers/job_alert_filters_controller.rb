class JobAlertFiltersController < ApplicationController
  before_action :find_job_alert_filter, only: [:update, :destroy, :toggle, :update_via_token]
  before_action :verify_management_token, only: [:toggle, :update_via_token]

  def create
    @job_alert = JobAlert.find(params[:job_alert_id])
    @job_alert_filter = @job_alert.job_alert_filters.build(job_alert_filter_params)

    if @job_alert_filter.save
      redirect_to manage_job_alert_path(token: @job_alert.management_token),
        notice: "Filter added successfully."
    else
      redirect_to manage_job_alert_path(token: @job_alert.management_token),
        alert: "Error adding filter: #{@job_alert_filter.errors.full_messages.join(", ")}"
    end
  end

  def update
    if @job_alert_filter.update(job_alert_filter_params)
      redirect_to manage_job_alert_path(token: @job_alert_filter.job_alert.management_token),
        notice: "Filter updated successfully."
    else
      redirect_to manage_job_alert_path(token: @job_alert_filter.job_alert.management_token),
        alert: "Error updating filter: #{@job_alert_filter.errors.full_messages.join(", ")}"
    end
  end

  def update_via_token
    if @job_alert_filter.update(job_alert_filter_params)
      redirect_to manage_job_alert_path(token: params[:token]),
        notice: "Filter updated successfully."
    else
      redirect_to manage_job_alert_path(token: params[:token]),
        alert: "Error updating filter: #{@job_alert_filter.errors.full_messages.join(", ")}"
    end
  end

  def toggle
    @job_alert_filter.update!(enabled: !@job_alert_filter.enabled)

    redirect_to manage_job_alert_path(token: params[:token]),
      notice: "Filter #{@job_alert_filter.enabled? ? "enabled" : "disabled"} successfully."
  end

  def destroy
    @job_alert_filter.destroy
    redirect_to manage_job_alert_path(token: @job_alert_filter.job_alert.management_token),
      notice: "Filter deleted successfully."
  end

  private

  def find_job_alert_filter
    @job_alert_filter = JobAlertFilter.find(params[:id])
  end

  def verify_management_token
    @job_alert = @job_alert_filter.job_alert
    redirect_to root_path, alert: "Invalid access token." unless @job_alert.management_token == params[:token]
  end

  def job_alert_filter_params
    params.require(:job_alert_filter).permit(:category, :region, :frequency, :enabled)
  end
end
