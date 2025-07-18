class JobOfferApplication < ApplicationRecord
  belongs_to :job_offer

  has_one_attached :cv

  validates :cv, antivirus: true
  def process
    # remove the CV file after 7 days from the job offer's valid till date at the moment it was created
    PurgeJobOfferApplicationFileJob.set(wait_until: determine_time).perform_later(id)
    JobApplicationMailer.application_email(job_offer_application: self).deliver_later
  end

  private

  def determine_time
    job_offer.expires_at + 7.days
  end
end
