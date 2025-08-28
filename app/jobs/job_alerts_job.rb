class JobAlertsJob < ApplicationJob
  queue_as :low_priority

  def perform(frequency)
    JobAlertsService.call(frequency.to_sym)
  end
end
