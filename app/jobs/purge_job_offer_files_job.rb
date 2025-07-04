# removes all files associated with a job offer through job_offer_applications

class PurgeJobOfferFilesJob < ActiveJob::Base
  queue_as :low_priority

  def perform(job_offer_id)
  end
end
