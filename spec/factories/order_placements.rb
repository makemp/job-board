FactoryBot.define do
  factory :order_placement do
    free_order { false }
    paid_at { nil }
    price { 100 }
    association :job_offer
    ready_to_be_placed { false }
    voucher_code { create(:voucher).code }
  end
end
