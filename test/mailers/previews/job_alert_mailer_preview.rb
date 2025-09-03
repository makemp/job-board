# Preview all emails at http://localhost:3000/rails/mailers/job_alert_mailer
class JobAlertMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/job_alert_mailer/confirmation_email
  def confirmation_email
    job_alert = JobAlert.new(
      email: "john.doe@example.com"
    )

    job_alert_filter = JobAlertFilter.new(
      name: "Drilling Jobs in Texas",
      category: "Drilling",
      region: "Texas",
      frequency: "weekly",
      confirmation_token: "sample_confirmation_token_123",
      job_alert: job_alert
    )

    # Mock the relationship so management_token works
    job_alert.define_singleton_method(:job_alert_filters) do
      arr = [job_alert_filter]  # Fix: should be job_alert_filter, not job_alert
      arr.define_singleton_method(:order) do |*_args|
        arr
      end
      arr
    end

    job_alert_filter.define_singleton_method(:job_alert) do
      job_alert
    end

    JobAlertMailer.confirmation_email(job_alert_filter)
  end
end
