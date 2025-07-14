FactoryBot.define do
  factory :job_offer do
    title { "Sample Job Title" }
    company_name { "Sample Company" }
    region { JobOffer::REGIONS.sample }
    category { JobOffer::CATEGORIES.sample }
    approved { true }
    apply_with_job_board { true }
    featured { false }
    association :employer
  end
end
