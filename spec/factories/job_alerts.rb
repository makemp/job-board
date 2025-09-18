# frozen_string_literal: true

FactoryBot.define do
  factory :job_alert do
    sequence(:email) { |n| "alert#{n}@example.com" }
    confirmed_at { nil }

    trait :confirmed do
      confirmed_at { Time.current }
    end
  end
end
