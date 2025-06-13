class OrderPlacement < ApplicationRecord
  belongs_to :job_offer, optional: true
  belongs_to :special_offer, optional: true

  validate :price_consistency

  delegate :employer, to: :job_offer, allow_nil: true

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
    stripe_payload.dig("invoice.payment_succeeded", "invoice_pdf")
  end

  private

  def price_consistency
    return unless ready_to_be_placed?
    return errors.add(:price, "must be a positive number or 0") if price.nil? || price < 0
    return errors.add(:price, "If free_order is true, price must be 0") if free_order && price > 0
    errors.add(:price, "If free_order is false, price must be greater than 0") if !free_order && price.zero?
  end
end
