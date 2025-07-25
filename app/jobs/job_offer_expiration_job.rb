# run in cron every minute to mark job offers as expired. Going through JobOfferActions grouped by job_offer_id max(created_at)

class JobOfferExpirationJob < ApplicationJob
  queue_as :default

  def perform
    results = JobOfferAction.joins(:job_offer)
      .where("job_offers.expired_on": nil)
      .where("job_offer_actions.action_type": JobOfferAction::TYPES_EXTENDING_EXPIRATION)
      .group("job_offers.id").select("max(job_offer_actions.valid_till)", "job_offers.id as job_offer_id")
      .having("max(job_offer_actions.valid_till) > ?", Time.current)
    JobOffer.where(id: results.map { it["job_offer_id"] }).each do |job_offer|
      job_offer.expire!
    end
  end
end
