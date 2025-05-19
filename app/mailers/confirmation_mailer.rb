class ConfirmationMailer < ApplicationMailer
  default from: "no-reply@example.com"

  def confirmation_instructions(employer, token)
    @employer = employer
    @token = token
    mail to: @employer.email, subject: "Email Confirmation Instructions"
  end
end
