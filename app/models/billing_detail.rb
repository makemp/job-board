class BillingDetail < ApplicationRecord
  belongs_to :employer
  validates :company_name, :tax_id, :address, :city, :zip, :country, presence: true
end
