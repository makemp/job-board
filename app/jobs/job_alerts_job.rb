class JobAlertsJob < ApplicationJob
  queue_as :low_priority

  def perform(arguments = {})
    Rails.logger.info "JobAlertsJob started with arguments: #{arguments.inspect}"
    arguments = arguments.deep_symbolize_keys
    job_offers_by_email = JobAlerts::FetchDataService.call(arguments[:frequency].to_sym)
    JobAlerts::SendEmailsService.call(job_offers_by_email)
    Rails.logger.info "JobAlertsJob completed"
  end
end
