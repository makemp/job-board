# == Schema Information
#
# Table name: job_offer_actions
#
#  id           :ulid             not null, primary key
#  action_type  :string
#  valid_till   :datetime         not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  job_offer_id :ulid             not null
#
# Indexes
#
#  idx_job_offer_actions_covering           (action_type,job_offer_id,valid_till) WHERE action_type IN ('created', 'extended')
#  index_job_offer_actions_on_job_offer_id  (job_offer_id)
#
# Foreign Keys
#
#  job_offer_id  (job_offer_id => job_offers.id)
#
class JobOfferAction < ApplicationRecord
  CREATED_TYPE = "created".freeze
  EXTENDED_TYPE = "extended".freeze

  TYPES = [CREATED_TYPE, EXTENDED_TYPE].freeze
  # index on these fields: idx_job_offer_actions_covering
  TYPES_EXTENDING_EXPIRATION = [CREATED_TYPE, EXTENDED_TYPE].freeze

  validates :action_type, presence: true, inclusion: {in: TYPES}

  belongs_to :job_offer
end
