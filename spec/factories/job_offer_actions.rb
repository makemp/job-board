# frozen_string_literal: true

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
FactoryBot.define do
  factory :job_offer_action do
    job_offer
    action_type { JobOfferAction::CREATED_TYPE }
    valid_till { 1.month.from_now }
  end
end
