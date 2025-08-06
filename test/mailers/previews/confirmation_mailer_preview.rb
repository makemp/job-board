class ConfirmationMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/confirmation_mailer/confirmation_instructions
  def confirmation_instructions
    employer = Employer.first || create_sample_employer
    token = "sample_confirmation_token_123456"
    ConfirmationMailer.confirmation_instructions(employer, token)
  end

  private

  def create_sample_employer
    Employer.new(
      id: 1,
      email: "newuser@samplecompany.com",
      company_name: "Sample Mining Corp",
      created_at: Time.current,
      updated_at: Time.current
    )
  end
end
