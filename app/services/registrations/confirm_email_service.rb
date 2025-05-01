class Registrations
  class ConfirmEmailService
    ConfirmationError = Class.new(StandardError)

    def initialize(token)
      @token = token
    end

    def call!
      employer = Employer.find_by(confirmation_token: @token)
      raise ConfirmationError, "Invalid token" if employer.blank?
      raise ConfirmationError, "Token expired" if confirmation_expired?(employer)

      employer.update!(confirmed_at: Time.current, confirmation_token: nil)
    end

    private

    def confirmation_expired?(employer)
      employer&.confirmation_sent_at && employer.confirmation_sent_at < 2.days.ago
    end
  end
end
