class EmployerLoginCodeMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/employer_login_code_mailer/send_code
  def send_code
    employer = Employer.first || create_sample_employer
    employer.update(login_code: "ABC123") # Set a sample login code
    EmployerLoginCodeMailer.send_code(employer)
  end

  private

  def create_sample_employer
    Employer.new(
      id: 1,
      email: "sample@example.com",
      company_name: "Sample Drilling Company",
      login_code: "ABC123",
      created_at: Time.current,
      updated_at: Time.current
    )
  end
end
