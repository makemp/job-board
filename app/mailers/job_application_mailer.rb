class JobApplicationMailer < ApplicationMailer
  def application_email(job_offer:, cv_read:, cv_original_filename:, comments:)
    @job_offer = job_offer
    attachments[cv_original_filename] = cv_read
    @comments = comments
    mail(
      to: @job_offer.application_destination,
      subject: "New Job Application for #{@job_offer.title}"
    )
  end
end
