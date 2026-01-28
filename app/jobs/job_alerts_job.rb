class JobAlertsJob < ApplicationJob
  queue_as :low_priority

  def perform(arguments = {})
    Rails.logger.info "JobAlertsJob started with arguments: #{arguments.inspect}"
    arguments = arguments.deep_symbolize_keys
    frequency = arguments[:frequency].to_sym

    unless guard(frequency)
      Rails.logger.info "JobAlertsJob skipped due to guard condition for frequency: #{frequency}"
      return
    end

    job_offers_by_email = JobAlerts::FetchDataService.call(frequency)
    JobAlerts::SendEmailsService.call(job_offers_by_email)
    Rails.logger.info "JobAlertsJob completed"
  end

  private

  def guard(frequency)
    current_time = Time.current
    return true if frequency == :monthly && current_time.day <= 7 && current_time.monday?
    return true if frequency == :weekly && current_time.day > 7 && current_time.monday?
    return true if frequency == :daily && !current_time.monday?
    false
  end
end
