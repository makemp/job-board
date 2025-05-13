class Voucher < ApplicationRecord
  DEFAULT_CODE = "STANDARD".freeze

  def price
    options["price"]
  end

  def required_approval?
    options["required_approval"] || false
  end

  def free_voucher?
    false
  end

  def enabled?
    enabled_till > Time.current
  end

  alias_method :enable?, :enabled?

  def apply(order_placement:, job_offer:)
    JobOffer.transaction do
      OrderPlacement.transaction do
        order_placement.update!(voucher_code: code, price: price, free_order: free_voucher?,
          ready_to_be_placed: true)
        job_offer.update!(approved: !required_approval?)
      end
    end
  end

  class << self
    def default_voucher
      @default_voucher ||= find_by!(code: DEFAULT_CODE)
    end

    def default_price
      default_voucher.options["price"]
    end
  end
end
