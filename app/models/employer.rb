class Employer < ApplicationRecord
  normalizes :email, with: -> { it.downcase.strip }

  has_many :job_offers

  has_many :order_placements, -> { where.not(paid_on: nil) }, through: :job_offers, source: :order_placement

  has_many :special_offers

  validates :company_name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :stripe_customer_id, uniqueness: true, allow_nil: true

  # Devise configuration
  devise :database_authenticatable, authentication_keys: [:email]

  # Active Storage attachment for employer logo

  has_one_attached :logo

  scope :valid, -> { where.not(confirmed_at: nil) }

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
  devise :database_authenticatable
end
