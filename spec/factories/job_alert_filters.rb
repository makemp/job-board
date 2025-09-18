# frozen_string_literal: true

FactoryBot.define do
  factory :job_alert_filter do
    association :job_alert
    frequency { :daily }
    region { "Canada" }
    category { "Engineering" }
    enabled { true }
  end
end
