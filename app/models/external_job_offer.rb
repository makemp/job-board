# == Schema Information
#
# Table name: job_offers
#
#  id                      :ulid             not null, primary key
#  application_destination :string
#  application_type        :string
#  approved                :boolean          default(FALSE), not null
#  category                :string
#  company_name            :string
#  custom_logo             :text
#  expired_manually        :datetime
#  expired_on              :datetime
#  offer_type              :string
#  options                 :json
#  overcategory            :string
#  region                  :string
#  slug                    :string
#  subregion               :string
#  terms_and_conditions    :boolean          default(FALSE)
#  title                   :string
#  type                    :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  employer_id             :ulid             not null
#
# Indexes
#
#  idx_job_offers_expired_on        (expired_on)
#  index_job_offers_on_employer_id  (employer_id)
#  index_job_offers_on_slug         (slug) UNIQUE
#
# Foreign Keys
#
#  employer_id  (employer_id => users.id)
#
class ExternalJobOffer < JobOffer
  validates :application_destination, presence: true, uniqueness: true

  before_create :generate_svg_logo

  HIDDEN_TYPE = "hidden".freeze

  scope :in_pending_queue, -> { where.not(type: HIDDEN_TYPE).joins(:order_placements).where(order_placements: {paid_on: nil}) }

  def employer_company_name
    the_company_name
  end

  def logo
    @logo ||= SvgLogoDecorator.new(custom_logo)
  end

  def hide!
    update!(type: HIDDEN_TYPE)
  end

  private

  def generate_svg_logo
    self.custom_logo = SvgLogoGenerator.generate_random_logo("External Job Offer")
  end
end
