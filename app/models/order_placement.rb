class OrderPlacement < ApplicationRecord
  belongs_to :job_offer, optional: true
  belongs_to :special_offer, optional: true

  validate :price_consistency

  delegate :employer, to: :job_offer, allow_nil: true

  after_update_commit :broadcast_if_paid, if: :recently_paid_with_invoice_generated?

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
    jop = jop.merge(logo: job_offer.logo) if job_offer.logo.present?
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
      partial: "completed_orders/status",
      locals: {order_placement: self}
    )
  end

  def recently_paid_with_invoice_generated?
    was_just_paid? && invoice_url.present?
  end

  private

  def was_just_paid?
    paid_at < 1.minute.ago
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
