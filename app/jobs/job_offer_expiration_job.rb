# run in cron every minute to mark job offers as expired. Going through JobOfferActions grouped by job_offer_id max(created_at)

class JobOfferExpirationJob < ApplicationJob
  queue_as :default

  def perform
    # Memory-optimized approach: use a single SQL query with subquery instead of loading results into Ruby
    expired_job_offer_ids = JobOffer.joins(:job_offer_actions)
      .where(expired_on: nil)
      .where(job_offer_actions: {action_type: JobOfferAction::TYPES_EXTENDING_EXPIRATION})
      .group("job_offers.id")
      .having("MAX(job_offer_actions.valid_till) < ?", Time.current)
      .pluck(:id)

    # Batch update instead of individual updates to reduce memory and database overhead
    if expired_job_offer_ids.any?
      # Use update_all for bulk update - much more memory efficient
      JobOffer.where(id: expired_job_offer_ids).update_all(expired_on: Time.current)

      Rails.logger.info "JobOfferExpirationJob: Expired #{expired_job_offer_ids.size} job offers"
    end
  end
end
