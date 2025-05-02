class Employer < ApplicationRecord
  has_many :job_offers  # dependent: :destroy hide?

  has_one_attached :logo

  scope :valid, -> { where.not(confirmed_at: nil) }

  def password_required?
    false
  end

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :validatable, :confirmable, :lockable
end
