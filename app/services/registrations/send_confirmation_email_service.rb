module Registrations
  class SendConfirmationEmailService
    ResendConfirmationError = Class.new(StandardError)

    def initialise(email)
      @email = email
    end

    def call!
      employer = Employer.find_by(email: @email)
      raise ResendConfirmationError, "Employer not found" if employer.blank?
      raise ResendConfirmationError, "Email already confirmed" if employer.confirmed_at.present?
      raise ResendConfirmationError, "Email is locked" if employer.locked_at.present?

      token = SecureRandom.hex(10)
      employer.update!(confirmation_token: token, confirmation_sent_at: Time.current)

      ConfirmationMailer.confirmation_instructions(employer, token).deliver_later
    rescue ActiveRecord::RecordInvalid => e
      raise ResendConfirmationError, e.message
    end
  end
end
