class PlaceOrder
  class CreateJobOffer
    include Interactor

    def call
      context.job_offer = context.employer.job_offers.create!(title:, company_name:,
        description:,
        location:,
        category:,
        terms_and_conditions:)
      context.job_offer.logo.attach(logo) if logo.present?
    end

    delegate :employer, to: :context
    delegate :title, :description, :location, :category, :company_name, :terms_and_conditions, to: :"context.info"
    delegate "voucher", "logo", to: :"context.info"
  end
end
