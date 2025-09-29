# == Schema Information
#
# Table name: staging_tokens
#
#  id         :integer          not null, primary key
#  value      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_staging_tokens_on_value  (value) UNIQUE
#
class StagingToken < ApplicationRecord
  validates :value, presence: true, uniqueness: true
end
