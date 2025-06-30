class JobApplicationMailer < ApplicationMailer
  def application_email
    @job_offer = params[:job_offer]
    @comments = params[:comments]
    attachments[params[:cv].original_filename] = params[:cv].read
    mail(
      to: @job_offer.employer.application_destination,
      subject: "New Job Application for #{@job_offer.title}"
    )
  end
end
