module JobOffers
  class Submit
    def self.call!(**params)
      new(**params).call
    end

    def initialize(**params)
      @params = params
    end

    def call
      Employer.transaction do
        JobOffer.transaction do
          OrderPlacement.transaction do
            PlaceFreeOrder.call(**params).redirect_url
          end
        end
      end
    end
  end
end
