# frozen_string_literal: true

FactoryBot.define do
  factory :job_offer_action do
    job_offer
    action_type { JobOfferAction::CREATED_TYPE }
    valid_till { 1.month.from_now }
  end
end
