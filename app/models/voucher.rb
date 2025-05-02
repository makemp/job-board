class Voucher < ApplicationRecord
  DEFAULT_CODE = "STANDARD".freeze

  def price
    options["price"]
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
