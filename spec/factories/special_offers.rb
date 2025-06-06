FactoryBot.define do
  factory :special_offer do
    sequence(:name) { |n| "Special Offer #{n}" }
    description { "This is a sample special offer." }
    number_of_vouchers { 5 }
    price { 200 }
  end
end
