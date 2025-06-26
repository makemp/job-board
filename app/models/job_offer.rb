class JobOffer < ApplicationRecord
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
  REGIONS = YAML.load_file(Rails.root.join("config", "regions.yml")).freeze
  APPLICATION_TYPES = %w[Link Form].freeze

  has_many :order_placements

  has_one :order_placement, -> { order(created_at: :desc) }, class_name: "OrderPlacement"

  belongs_to :employer

  scope :valid, -> do
    joins(:employer).where.not(employers: {confirmed_at: nil}).where("expires_at > ?", Time.current)
  end

  has_rich_text :description

  def expire_manually!
    time = Time.current
    update!(expires_at: time, expires_manually: time)
  end

  def expired?
    expires_at < Time.current
  end

  delegate :logo, to: :employer
end
