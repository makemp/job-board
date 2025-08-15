module JobOffers
  class CreateExternalJobOffer
    def self.call(job_offer_params)
      new(job_offer_params).call
    end

    def self.employer
      return @employer if @employer.present?

      # Create or find the employer for external job offers
      # This is a placeholder; you can customize the company_name and email as needed
      @employer = Employer.find_or_create_by!(company_name: "External Job Offers",
                                              email: "external@external.com")
      @employer.update(confirmed_at: Time.current)

      @employer.reload
    end

    def initialize(job_offer_params)
      @job_offer_params = job_offer_params
    end



    def call
      job_offer = ExternalJobOffer.create!(params)
      job_offer.order_placements.create!(paid_on: Time.current)
      job_offer.job_offer_actions.create!(action_type: JobOfferAction::CREATED_TYPE,
                                          valid_till: Time.current + Voucher.default_offer_duration)
    end

    private

    def params
      JSON.parse(job_offer_params)
          .merge(employer: self.class.employer,
                 overcategory: JobOffer::CATEGORIES.overcategory_for(job_offer_params["category"]))
    end

    attr_reader :job_offer_params
  end
end