class EmployerLoginCodeMailer < ApplicationMailer

  def send_code(employer)
    @employer = employer.reload
    @code = employer.login_code
    mail(to: @employer.email, subject: 'Your login code')
  end
end

