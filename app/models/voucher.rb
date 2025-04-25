class Voucher < ApplicationRecord
  DEFAULT_CODE = "STANDARD".freeze

  class << self
    def default_price
      @default_price ||= find_by!(code: DEFAULT_CODE).options["price"]
    end
  end
end
