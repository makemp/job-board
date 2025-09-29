# == Schema Information
#
# Table name: vouchers
#
#  id           :ulid             not null, primary key
#  code         :string           not null
#  enabled_till :datetime         default(2225-09-11 17:53:07.328950000 UTC +00:00)
#  options      :json
#  type         :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
FactoryBot.define do
  factory :free_voucher, class: "FreeVoucher" do
    sequence(:code) { |n| "FREEVOUCHER#{n}" }
    options { {"price" => 0, "required_approval" => false} }
    enabled_till { 1.day.from_now }
  end
end
