class ConfirmationMailer < ApplicationMailer
  def confirmation_instructions(employer, token)
    @employer = employer
    @token = token
    mail to: @employer.email, subject: "Email Confirmation Instructions"
  end
end
