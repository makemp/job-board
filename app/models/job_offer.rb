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

  APPLICATION_TYPE_LINK = "Link".freeze
  APPLICATION_TYPE_FORM = "Form".freeze
  APPLICATION_TYPES = [APPLICATION_TYPE_FORM, APPLICATION_TYPE_LINK].freeze

  normalizes :application_destination, with: -> { it.downcase.strip }

  has_many :order_placements

  has_one :order_placement, -> { order(created_at: :desc) }, class_name: "OrderPlacement"

  has_many :job_offer_actions, dependent: :destroy

  has_many :job_offer_applications, dependent: :destroy

  belongs_to :employer

  scope :valid, -> do
    joins(:employer).where.not(employers: {confirmed_at: nil}).where(expired_on: nil)
  end

  has_rich_text :description

  def expire_manually!
    time = Time.current
    update!(expired_on: time, expired_manually: time)
  end

  def expired?
    expired_on.present?
  end

  def expire!
    update!(expired_on: Time.current) unless expired?
  end

  def expires_at
    job_offer_actions
      .where(action_type: JobOfferAction::TYPES_EXTENDING_EXPIRATION)
      .order(:valid_till).last&.valid_till || Time.current # fallback just to prevent nil value but shouldn't happen
  end

  delegate :logo, to: :employer
  delegate :paid_on, to: :order_placement, allow_nil: true
end
