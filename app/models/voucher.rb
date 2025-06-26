class Voucher < ApplicationRecord
  DEFAULT_CODE = "STANDARD".freeze

  def price
    options["price"]
  end

  # How many days the job offer is valid
  def offer_duration
    options["offer_duration"]
  end

  def offer_duration_words
    "#{(offer_duration / 1.day).to_i} days"
  end

  def required_approval?
    options["required_approval"] || false
  end

  def free_voucher?
    false
  end

  # How many days the voucher is valid
  def enabled?
    enabled_till > Time.current
  end

  alias_method :enable?, :enabled?

  def apply(order_placement:, job_offer:)
    order_placement.update!(voucher_code: code, price: price, free_order: free_voucher?, ready_to_be_placed: true)
    job_offer.update!(approved: !required_approval?, expires_at: ActiveSupport::Duration.build(offer_duration).from_now)
  end

  def soft_apply(job_offer_form)
    job_offer_form.price = price
  end

  def can_apply?(job_offer_form_)
    enabled?
  end

  class << self
    def default_voucher
      @default_voucher ||= find_by!(code: DEFAULT_CODE)
    end

    def default_price
      default_voucher.options["price"]
    end

    # how many days the job offer is valid
    def default_offer_duration
      default_voucher.options["offer_duration"]
    end

    def default_offer_duration_words
      "#{(default_offer_duration / 1.day).to_i} days"
    end
  end
end
