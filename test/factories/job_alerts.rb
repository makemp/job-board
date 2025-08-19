FactoryBot.define do
  factory :job_alert do
    user { nil }
    email { "MyString" }
    category { "MyString" }
    region { "MyString" }
    frequency { "MyString" }
    active { false }
    name { "MyString" }
  end
end
