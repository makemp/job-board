FactoryBot.define do
  factory :billing_detail do
    association :employer
    company_name { "Company Name" }
    tax_id { "123456789" }
    address { "123 Main St" }
    city { "City" }
    zip { "12345" }
    country { "Country" }
  end
end
