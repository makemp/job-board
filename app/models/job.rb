require_relative "regions"
class Job < ApplicationRecord
  CATEGORIES = %w[Drilling Mining Engineering Safety Technicians].freeze

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

  delegate :logo, to: :employer

  # validates :title, :location, :company, :description, presence: true
end
