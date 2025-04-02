class Job < ApplicationRecord
  belongs_to :employer

  scope :valid, -> do
    joins(:employer).where.not(employers: {confirmed_at: nil}).where.not(employers: {approved_at: nil}).where(employers: {disabled_at: nil})
  end

  # validates :title, :location, :company, :description, presence: true
end
