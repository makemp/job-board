class ContactMailer < ApplicationMailer
  default from: "no-reply@example.com"

  def contact_email(contact)
    @contact = contact
    mail(to: "support@example.com", subject: "New Contact Form Submission")
  end
end
