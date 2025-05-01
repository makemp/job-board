class PlaceFreeOrder
  class CreateOrFindEmployer
    include Interactor

    def call
      # Find or create the employer based on the provided parameters
      employer = Employer.find_or_create_by(email:)

      context.fail!(error: "Email is locked.") if employer.locked_at.present?
      # TODO use list of wonky emails to not send emails to these people

      context.employer = employer
    end

    delegate :email, to: :"context.info"
  end
end
