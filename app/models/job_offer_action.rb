class JobOfferAction < ApplicationRecord
  TYPES = %w[created extended].freeze

  # index on these fields: idx_job_offer_actions_covering
  TYPES_EXTENDING_EXPIRATION = %w[created extended].freeze

  validates :action_type, presence: true, inclusion: {in: TYPES}

  belongs_to :job_offer
end
