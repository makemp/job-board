# == Schema Information
#
# Table name: job_alert_filters
#
#  id                 :ulid             not null, primary key
#  category           :string
#  confirmation_token :string
#  confirmed_at       :datetime
#  enabled            :boolean          default(FALSE)
#  frequency          :string
#  region             :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  job_alert_id       :ulid             not null
#
# Indexes
#
#  index_job_alert_filters_on_job_alert_id  (job_alert_id)
#
# Foreign Keys
#
#  job_alert_id  (job_alert_id => job_alerts.id)
#
class JobAlertFilter < ApplicationRecord
  belongs_to :job_alert, inverse_of: :job_alert_filters

  def active?
    enabled? && confirmed_at.present?
  end
end
