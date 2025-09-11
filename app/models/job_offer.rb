class JobOffer < ApplicationRecord
  include Sluggi::Slugged

  CATEGORIES = Categories
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

  normalizes :application_destination, with: -> { it.strip }

  has_many :order_placements, as: :orderable

  has_one :order_placement, -> { order(created_at: :desc) }, class_name: "OrderPlacement", inverse_of: :orderable

  has_many :job_offer_actions, dependent: :destroy

  has_many :job_offer_applications, dependent: :destroy

  belongs_to :employer, class_name: "Employer", inverse_of: :job_offers

  has_one :recent_action,
    -> {
      where(action_type: JobOfferAction::TYPES_EXTENDING_EXPIRATION)
        .order("job_offer_actions.created_at": :desc)
    },
    class_name: "JobOfferAction", foreign_key: :job_offer_id

  # Memory-optimized scope for index queries
  scope :for_index, -> do
    select(:id, :title, :company_name, :region, :subregion, :category, :overcategory, :created_at, :updated_at, :slug, :expired_on, :employer_id)
      .includes(:employer, :order_placement)
      .where(expired_on: nil)
      .joins(:employer)
      .where.not(users: {confirmed_at: nil})
      .joins("LEFT JOIN order_placements ON order_placements.orderable_id = job_offers.id AND order_placements.orderable_type = 'JobOffer'")
      .where.not(order_placements: {paid_on: nil})
  end

  scope :valid, -> do
    includes(:employer, :recent_action).where.not(users: {confirmed_at: nil}).where(expired_on: nil)
  end

  scope :valid_recent, -> do
    valid.where("job_offer_actions.created_at >= ?", 30.days.ago)
  end

  scope :paid, -> do
    includes(:order_placement).where.not(order_placements: {paid_on: nil})
  end

  scope :sorted, -> do
    joins("INNER JOIN (SELECT job_offer_id, MAX(created_at) AS max_created_at
                                                   FROM job_offer_actions GROUP BY job_offer_id)
    max_actions ON job_offers.id = max_actions.job_offer_id").order(type: :asc, max_created_at: :desc)
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
    ["#{the_company_name}-#{title}-#{region}-#{category}",
      "#{the_company_name}-#{title}",
      "#{the_company_name}-#{title}-#{Time.current.to_i}"]
  end

  def slug_value_changed?
    title_changed? || region_changed? || category_changed? || employer.company_name_changed?
  end

  def the_company_name
    company_name.presence || employer&.company_name || "Unknown Company"
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

  # Memory-optimized method to avoid loading all job_offer_actions into memory
  def expires_at
    job_offer_actions
      .select { JobOfferAction::TYPES_EXTENDING_EXPIRATION.include? it.action_type }
      .max_by { it.valid_till }&.valid_till || Time.current # fallback just to prevent nil value but shouldn't happen
  end

  def employer_company_name
    the_company_name
  end

  def self.filter_by_category(category)
    overcategory_check = CATEGORIES.categories_for(category).present?
    if overcategory_check
      where(overcategory: category)
    else
      where(category: category)
    end
  end

  def matches_category?(foreign_category)
    return true if category == foreign_category
    true if CATEGORIES.categories_for(foreign_category).include? category
  end

  delegate :logo, to: :employer
  delegate :paid_on, to: :order_placement, allow_nil: true
end
