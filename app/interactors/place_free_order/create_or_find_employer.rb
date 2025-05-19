class PlaceFreeOrder
  class CreateOrFindEmployer
    include Interactor

    def call
      # Find or create the employer based on the provided parameters
      employer = Employer.find_by(email:)

      context.is_new_employer = true unless employer

      employer ||= Employer.create!(email:)

      context.employer = employer
    end

    delegate :email, to: :"context.info"
  end
end
