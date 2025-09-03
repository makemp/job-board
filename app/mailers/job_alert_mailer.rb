class JobAlertMailer < ApplicationMailer
  def confirmation_email(job_alert_filter)
    @job_alert_filter = job_alert_filter
    @job_alert = job_alert_filter.job_alert
    @confirmation_url = confirm_job_alert_url(token: @job_alert_filter.confirmation_token)
    @manage_url = manage_job_alert_url(token: @job_alert.management_token)

    mail(
      to: @job_alert.email,
      subject: "Confirm your job alert!"
    )
  end

  def digest_email(job_alert, job_offers)
    @job_offers = job_offers
    @job_alert = job_alert
    mail(
      to: job_alert.email,
      subject: "Your job alert - #{job_offers.count} new job#{"s" if job_offers.count > 1}!"
    )
  end
end
