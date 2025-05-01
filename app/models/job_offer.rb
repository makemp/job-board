require_relative "regions"
class JobOffer < ApplicationRecord
  CATEGORIES = %w[Drilling Mining Engineering Safety Technicians].freeze

  has_one :order_placement

  HIGHLIGHTED_REGIONS = ["Australia",
    "Canada",
    "USA",
    "UAE",
    "Chile",
    "South Africa",
    "Kazakhstan",
    "North Sea - Offshore",
    "Gulf of America (Mexico) - Offshore",
    "West Africa - Offshore",
    "Remote/Rotational",
    "Other"].freeze
  REGIONS = ::REGIONS

  belongs_to :employer

  scope :valid, -> do
    joins(:employer).where.not(employers: {confirmed_at: nil}).where.not(employers: {approved_at: nil}).where(employers: {disabled_at: nil})
  end

  has_rich_text :description

  delegate :logo, to: :employer
end
