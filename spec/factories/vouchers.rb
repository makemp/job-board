FactoryBot.define do
  factory :voucher do
    sequence(:code) { |n| "VOUCHER#{n}" }
    options { {"price" => 100, "required_approval" => false} }
    enabled_till { 1.day.from_now }
  end
end
