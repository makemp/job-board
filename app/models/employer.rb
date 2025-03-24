class Employer < ApplicationRecord
  has_many :jobs  # dependent: :destroy hide?

  scope :valid, -> { where.not(confirmed_at: nil).where.not(approved_at: nil).where(disabled_at: nil) }

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :validatable, :confirmable, :lockable
end
