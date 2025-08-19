class JobAlert < ApplicationRecord
  belongs_to :user, optional: true # Allow guest alerts without user account
  has_many :job_alert_filters, dependent: :destroy, inverse_of: :job_alert
end
