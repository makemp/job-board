FactoryBot.define do
  factory :free_voucher, class: "FreeVoucher" do
    sequence(:code) { |n| "FREEVOUCHER#{n}" }
    options { {"price" => 0, "required_approval" => false} }
    enabled_till { 1.day.from_now }
  end
end
