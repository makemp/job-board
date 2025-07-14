class PlaceOrder
  class CreateJobOffer
    include Interactor

    def call
      context.job_offer = context.employer.job_offers.create!(
        title:,
        company_name:,
        description:,
        region:,
        subregion:,
        category:,
        terms_and_conditions:,
        application_type:,
        application_destination:
      )
      context.job_offer.logo.attach(logo) if logo.present?
    end

    delegate :employer, to: :context
    delegate(*JobOfferForm.attribute_names, to: :"context.info")
    delegate "voucher", "logo", to: :"context.info"
  end
end
