module JobAlerts
  class SendEmailsService
    def self.call(job_offers_by_email)
      new(job_offers_by_email).call
    end

    def initialize(job_offers_by_email)
      @job_offers_by_email = job_offers_by_email
    end

    def call
      @job_offers_by_email.each do |job_alert_id, job_offers|
        next if job_alert_id.blank? || job_offers.blank?
        job_alert = JobAlert.find(job_alert_id)
        next if job_alert.blank?

        JobAlertMailer.digest_email(job_alert, job_offers).deliver_later
      end
    end
  end
end
