# removes all files associated with a job offer through job_offer_applications

class PurgeJobOfferApplicationFile < ActiveJob::Base
  queue_as :low_priority

  def perform(job_application_id)
    job_application = JobOfferApplication.find_by(id: job_application_id)
    return unless job_application
    return unless job_application.cv.attached?

    Rails.logger.info "Purging CV for JobOfferApplication ID: #{job_application.id}"
    job_application.cv.purge_later
  end
end
