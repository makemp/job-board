class ContactMailer < ApplicationMailer
  def contact_email(contact_params)
    @contact = Contact.new(contact_params)
    mail(to: "support@drillcrew.work", subject: "New Contact Form Submission")
  end
end
