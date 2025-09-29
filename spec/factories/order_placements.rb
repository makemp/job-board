# == Schema Information
#
# Table name: order_placements
#
#  id                    :ulid             not null, primary key
#  free_order            :boolean          default(FALSE), not null
#  job_offer_form_params :json
#  orderable_type        :string
#  paid_on               :datetime
#  payment_broadcasted   :boolean          default(FALSE)
#  price                 :integer
#  ready_to_be_placed    :boolean          default(FALSE)
#  session_token         :string
#  stripe_payload        :json
#  voucher_code          :string           default("STANDARD"), not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  orderable_id          :ulid
#  stripe_session_id     :string
#
# Indexes
#
#  index_order_placements_on_orderable          (orderable_type,orderable_id)
#  index_order_placements_on_stripe_session_id  (stripe_session_id) UNIQUE
#
FactoryBot.define do
  factory :order_placement do
    free_order { false }
    paid_on { nil }
    price { 100 }
    association :job_offer
    ready_to_be_placed { false }
    voucher_code { create(:voucher).code }
  end
end
