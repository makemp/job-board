class JobAlertFilter < ApplicationRecord
  belongs_to :job_alert, inverse_of: :job_alert_filters

  def active?
    enabled? && confirmed_at.present?
  end
end
