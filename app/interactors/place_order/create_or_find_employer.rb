class PlaceOrder
  class CreateOrFindEmployer
    include Interactor

    def call
      # Find or create the employer based on the provided parameters
      employer = Employer.find_by(email:)

      context.is_new_employer = true unless employer

      employer ||= Employer.create!(email:)

      # We only want to set the company name:
      # 1. If the employer is new
      # 2. If the employer is not confirmed yet but previously tied to be registered
      employer.update!(company_name:) unless employer.confirmed_at

      context.employer = employer
    end

    private

    def company_name
      context.info.company_name
    end

    delegate :email, to: :"context.info"
  end
end
