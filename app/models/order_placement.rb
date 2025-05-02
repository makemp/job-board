class OrderPlacement < ApplicationRecord
  belongs_to :job_offer

  validate :price_consistency

  def price_consistency
    errors.add(:price, "must be a positive number or 0") if price.nil? || price < 0
    errors.add(:price, "If free_order is true, price must be 0") if free_order && price > 0
    errors.add(:price, "If free_order is false, price must be greater than 0") if !free_order && price.zero?
  end
end
