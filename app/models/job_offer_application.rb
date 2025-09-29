# == Schema Information
#
# Table name: job_offer_applications
#
#  id           :ulid             not null, primary key
#  comments     :text             not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  job_offer_id :ulid             not null
#
# Indexes
#
#  index_job_offer_applications_on_job_offer_id  (job_offer_id)
#
# Foreign Keys
#
#  job_offer_id  (job_offer_id => job_offers.id)
#
class JobOfferApplication < ApplicationRecord
  belongs_to :job_offer

  has_one_attached :cv

  def process
    return unless cv.attached?
    # remove the CV file after 7 days from the job offer's valid till date at the moment it was created
    PurgeJobOfferApplicationFileJob.set(wait_until: determine_time).perform_later(id)
    return unless VirusScanService.new(cv_path).call
    JobApplicationMailer.application_email(job_offer_application_id: id).deliver_later
  end

  private

  def cv_path
    ActiveStorage::Blob.service.path_for(cv.key)
  end

  def determine_time
    job_offer.expires_at + 7.days
  end
end
