FactoryBot.define do
  factory :employer do
    sequence(:email) { |n| "user#{n}@example.com" }
    company_name { "Employer Name" }
    confirmed_at { Time.current }
  end
end
