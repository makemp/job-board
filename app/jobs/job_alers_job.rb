class JobAlertsJob < ApplicationJob
  queue_as :default

  def perform(params = {})
    JobAlertService.new(params).call
  end
end