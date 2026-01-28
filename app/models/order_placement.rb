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
class OrderPlacement < ApplicationRecord
  belongs_to :orderable, polymorphic: true, optional: true, inverse_of: :order_placements

  validate :price_consistency

  delegate :employer, to: :orderable, allow_nil: true

  after_update_commit :broadcast_if_paid, if: :recently_paid_with_invoice_generated?
  after_create_commit :purge_stripe_data_later

  encrypts :stripe_payload

  def free?
    read_attribute("free_order") && price.zero?
  end

  def voucher
    @voucher ||= Voucher.find_by(code: voucher_code)
  end

  def free_order?
    free?
  end

  def job_offer_form_attributes
    jop = job_offer_form_params["attributes"]
    jop = jop.merge(logo: orderable.logo) if orderable.respond_to?(:logo) && orderable.logo.present?
    jop
  end

  def email
    job_offer_form_params.dig("attributes", "email")
  end

  def invoice_url
    invoice_stripe_payload.dig("invoice_pdf")
  end

  def description
    return unless lines_data
    lines_data.map { it["description"] }.join(", ")
  end

  def broadcast_if_paid
    broadcast_replace_to(
      # Stream: Broadcast to the private channel for this specific record.
      self,
      # Target: The DOM ID of the container to replace.
      # Must match the ID in the view: "order_placement_123_status"
      target: ActionView::RecordIdentifier.dom_id(self, :completed),

      # Content: Render the partial with the updated object state.
      partial: "completed_orders/processed",
      locals: {order_placement: self}
    )
  end

  def recently_paid_with_invoice_generated?
    saved_change_to_stripe_payload? && invoice_url.present?
  end

  private

  def purge_stripe_data_later
    PurgeStripeDataOnOrderPlacement.set(wait: 7.days).perform_later(id)
  end

  def invoice_stripe_payload
    return @invoice_stripe_payload if @invoice_stripe_payload.present?
    invoice_stripe_payload_ = stripe_payload.dig("invoice.payment_succeeded")
    @invoice_stripe_payload = invoice_stripe_payload_ || {}
  end

  def lines_data
    lines.dig("data") || {}
  end

  def lines
    invoice_stripe_payload.dig("lines") || {}
  end

  def price_consistency
    return unless ready_to_be_placed?
    return errors.add(:price, "must be a positive number or 0") if price.nil? || price < 0
    return errors.add(:price, "If free_order is true, price must be 0") if free_order && price > 0
    errors.add(:price, "If free_order is false, price must be greater than 0") if !free_order && price.zero?
  end
end
