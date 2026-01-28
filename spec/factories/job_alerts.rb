# frozen_string_literal: true

# == Schema Information
#
# Table name: job_alerts
#
#  id               :ulid             not null, primary key
#  confirmed_at     :datetime
#  email            :string
#  management_token :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  user_id          :ulid
#
# Indexes
#
#  index_job_alerts_on_user_id  (user_id)
#
# Foreign Keys
#
#  user_id  (user_id => users.id)
#
FactoryBot.define do
  factory :job_alert do
    sequence(:email) { |n| "alert#{n}@example.com" }
    confirmed_at { nil }

    trait :confirmed do
      confirmed_at { Time.current }
    end
  end
end
