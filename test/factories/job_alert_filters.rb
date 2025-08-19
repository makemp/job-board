FactoryBot.define do
  factory :job_alert_filter do
    job_alert { nil }
    category { "MyString" }
    region { "MyString" }
    frequency { "MyString" }
    active { false }
    confirmation_token { "MyString" }
    confirmed_at { "2025-08-18 21:12:46" }
    name { "MyString" }
  end
end
