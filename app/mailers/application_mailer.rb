class ApplicationMailer < ActionMailer::Base
  default from: ENV["EMAIL_SENDER_ADDRESS"]
  layout "mailer"
end
