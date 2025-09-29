# == Schema Information
#
# Table name: vouchers
#
#  id           :ulid             not null, primary key
#  code         :string           not null
#  enabled_till :datetime         default(2225-09-29 10:22:39.845463000 UTC +00:00)
#  options      :json
#  type         :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
FactoryBot.define do
  factory :voucher do
    sequence(:code) { |n| "VOUCHER#{n}" }
    options { {"price" => 100, "required_approval" => false} }
    enabled_till { 1.day.from_now }
  end
end
