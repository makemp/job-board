# == Schema Information
#
# Table name: users
#
#  id                     :ulid             not null, primary key
#  closed_at              :datetime
#  company_name           :string
#  confirmation_sent_at   :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :string
#  email                  :string
#  encrypted_password     :string
#  failed_attempts        :integer          default(0), not null
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :string
#  locked_at              :datetime
#  login_code             :string
#  login_code_sent_at     :datetime
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  sign_in_count          :integer          default(0), not null
#  type                   :string
#  unconfirmed_email      :string
#  unlock_token           :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  stripe_customer_id     :string
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
class Employer < User
  normalizes :email, with: -> { it.downcase.strip }

  default_scope { where.not(email: nil) }

  has_many :job_offers, foreign_key: :employer_id

  has_many :order_placements, -> { where.not(paid_on: nil) }, through: :job_offers, source: :order_placement

  has_many :special_offers

  validates :company_name, presence: true, unless: ->(employer) { employer.closed_at.present? }
  validates :email, presence: true, uniqueness: true, unless: ->(employer) { employer.closed_at.present? }
  validates :stripe_customer_id, uniqueness: true, allow_nil: true

  # Devise configuration
  devise :database_authenticatable, :rememberable, authentication_keys: [:email]

  # Active Storage attachment for employer logo

  has_one_attached :logo, service: Rails.env

  scope :valid, -> { where.not(confirmed_at: nil).where(closed_at: nil) }

  def password_required?
    false
  end

  def latest_order_placement
    job_offers.order(created_at: :desc).first&.order_placement
  end

  def stripe_customer
    return nil if stripe_customer_id.blank?

    @stripe_customer ||= Stripe::Customer.retrieve(stripe_customer_id)
  rescue Stripe::InvalidRequestError => e
    Rails.logger.error "Stripe customer retrieval failed. Employer id: #{id}, error message: #{e.message}"
    nil
  end

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  # devise :database_authenticatable
end
