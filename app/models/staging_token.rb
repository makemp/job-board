class StagingToken < ApplicationRecord
  validates :value, presence: true, uniqueness: true
end
