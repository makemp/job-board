class JobOfferAction < ApplicationRecord
  CREATED_TYPE = "created".freeze
  EXTENDED_TYPE = "extended".freeze

  TYPES = [CREATED_TYPE, EXTENDED_TYPE].freeze
  # index on these fields: idx_job_offer_actions_covering
  TYPES_EXTENDING_EXPIRATION = [CREATED_TYPE, EXTENDED_TYPE].freeze

  validates :action_type, presence: true, inclusion: {in: TYPES}

  belongs_to :job_offer
end
