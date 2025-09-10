class JobAlertsJob < ApplicationJob
  queue_as :low_priority

  def perform(arguments = {})
    job_offers_by_email = JobAlerts::FetchDataService.call(arguments[:frequency].to_sym)
    JobAlerts::SendEmailsService.call(job_offers_by_email)
  end
end
