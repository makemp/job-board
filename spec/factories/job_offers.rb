FactoryBot.define do
  factory :job_offer do
    title { "Sample Job Title" }
    company_name { "Sample Company" }
    region { JobOffer::REGIONS.sample }
    overcategory { JobOffer::CATEGORIES.overcategories_names.sample }
    category { |job_offer| JobOffer::CATEGORIES.categories_for(job_offer.overcategory).sample }
    approved { true }
    apply_with_job_board { true }
    featured { false }
    association :employer
  end
end
