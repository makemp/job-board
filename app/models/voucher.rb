class Voucher < ApplicationRecord
  DEFAULT_CODE = "STANDARD".freeze

  def self.finish_apply!(order_placement)
    return unless order_placement&.voucher_code
    voucher = find_by!(code: order_placement.voucher_code)
    voucher.update!(options: voucher.options.merge({usage_count: voucher.usage_count + 1}))
  end

  def price
    options["price"]
  end

  def num_of_usages
    options["num_of_usages"] || 1
  end

  def usage_count
    options["usage_count"] || 0
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
    enabled_till > Time.current && (usage_count < num_of_usages)
  end

  alias_method :enable?, :enabled?

  # This method is used in context of transaction, see JobOffers::Submit
  def apply(order_placement:, job_offer:)
    order_placement.update!(voucher_code: code, price: price, free_order: free_voucher?, ready_to_be_placed: true)
    job_offer.update!(approved: !required_approval?)
    job_offer.job_offer_actions.create!(action_type: JobOfferAction::CREATED_TYPE,
      valid_till: Time.current + offer_duration)
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
