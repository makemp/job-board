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
            return PlaceOrder.call(**params).redirect_path
          end
        end
      end
    end

    private

    attr_reader :params
  end
end
