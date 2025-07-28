class JobApplicationMailer < ApplicationMailer
  def application_email(job_offer_application_id:)
    job_offer_application = JobOfferApplication.find(job_offer_application_id)
    @job_offer = job_offer_application.job_offer
    attachments[job_offer_application.cv.original_filename] = job_offer_application.cv
    @comments = job_offer_application.comments
    mail(
      to: @job_offer.application_destination,
      subject: "New Job Application for #{@job_offer.title}"
    )
  end
end
