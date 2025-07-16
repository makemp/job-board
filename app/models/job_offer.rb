class JobOffer < ApplicationRecord
  include Sluggi::Slugged

  CATEGORIES = %w[Drilling Mining Engineering Safety Technicians].freeze
  HIGHLIGHTED_REGIONS = ["Australia",
    "Canada",
    "USA",
    "Argentina",
    "Brazil",
    "Colombia",
    "Peru",
    "UAE",
    "Saudi Arabia",
    "Qatar",
    "Kuwait",
    "Iraq",
    "Chile",
    "South Africa",
    "Kazakhstan",
    "North Sea - Offshore",
    "Gulf of America (Mexico) - Offshore",
    "West Africa - Offshore",
    "Remote/Rotational"].sort.freeze
  REGIONS = YAML.load_file(Rails.root.join("config", "regions.yml")).freeze

  APPLICATION_TYPE_LINK = "Link".freeze
  APPLICATION_TYPE_FORM = "Form".freeze
  APPLICATION_TYPES = [APPLICATION_TYPE_FORM, APPLICATION_TYPE_LINK].freeze

  normalizes :application_destination, with: -> { it.downcase.strip }

  has_many :order_placements

  has_one :order_placement, -> { order(created_at: :desc) }, class_name: "OrderPlacement", inverse_of: :job_offer

  has_many :job_offer_actions, dependent: :destroy

  has_many :job_offer_applications, dependent: :destroy

  belongs_to :employer, class_name: "Employer", inverse_of: :job_offers

  has_one :recent_action,
    -> {
      where(action_type: JobOfferAction::TYPES_EXTENDING_EXPIRATION)
        .order("job_offer_actions.created_at": :desc)
    },
    class_name: "JobOfferAction", foreign_key: :job_offer_id

  scope :valid, -> do
    eager_load(:employer, :recent_action).where.not(users: {confirmed_at: nil}).where(expired_on: nil)
  end

  scope :paid, -> do
    eager_load(:order_placement).where.not(order_placements: {paid_on: nil})
  end

  scope :sorted, -> do
    joins("INNER JOIN (SELECT job_offer_id, MAX(created_at) AS max_created_at
                                                   FROM job_offer_actions GROUP BY job_offer_id)
    max_actions ON job_offers.id = max_actions.job_offer_id").order(max_created_at: :desc)
  end

  has_rich_text :description

  def expire_manually!(additional_params = {})
    time = Time.current
    if expired?
      update!(**additional_params) if additional_params.present?
    else
      update!(expired_on: time, expired_manually: time, **additional_params)
    end
  end

  def slug_candidates
    ["#{employer.company_name}-#{title}-#{region}-#{category}",
      "#{employer.company_name}-#{title}",
      "#{employer.company_name}-#{title}-#{Time.current.to_i}"]
  end

  def slug_value_changed?
    title_changed? || region_changed? || category_changed? || employer.company_name_changed?
  end

  def expired?
    expired_on.present?
  end

  def expire!
    update!(expired_on: Time.current) unless expired?
  end

  def enlisted_recently_at
    recent_action&.created_at || Time.current
  end

  # use select here to cache the result
  def expires_at
    job_offer_actions
      .select { JobOfferAction::TYPES_EXTENDING_EXPIRATION.include? it.action_type }
      .max_by { it.valid_till }&.valid_till || Time.current # fallback just to prevent nil value but shouldn't happen
  end

  def employer_company_name
    employer.company_name
  end

  delegate :logo, to: :employer
  delegate :paid_on, to: :order_placement, allow_nil: true
end
