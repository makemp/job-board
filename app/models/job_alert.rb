# == Schema Information
#
# Table name: job_alerts
#
#  id               :ulid             not null, primary key
#  confirmed_at     :datetime
#  email            :string
#  management_token :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  user_id          :ulid
#
# Indexes
#
#  index_job_alerts_on_user_id  (user_id)
#
# Foreign Keys
#
#  user_id  (user_id => users.id)
#
class JobAlert < ApplicationRecord
  belongs_to :user, optional: true # Allow guest alerts without user account
  has_many :job_alert_filters, dependent: :destroy, inverse_of: :job_alert

  scope :confirmed, -> { where.not(confirmed_at: nil) }

  def active?
    confirmed_at.present?
  end
end
