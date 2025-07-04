class JobOfferApplication < ApplicationRecord
  belongs_to :job_offer

  has_one_attached :cv
end
