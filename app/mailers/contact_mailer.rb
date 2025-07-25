class ContactMailer < ApplicationMailer
  def contact_email(contact)
    @contact = contact
    mail(to: "support@drillcrew.work", subject: "New Contact Form Submission")
  end
end
