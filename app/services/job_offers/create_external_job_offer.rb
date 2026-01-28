module JobOffers
  class CreateExternalJobOffer
    def self.company_name(url)
      base = URI.parse(url).host&.downcase

      case base
      when /shell\.com/
        "Shell"
      when /exxonmobil\.com/
        "ExxonMobil"
      when /totalenergies\.com/
        "TotalEnergies"
      when /bp\.com/
        "BP"
      when /halliburton\.com/
        "Halliburton"
      when /bakerhughes\.com/
        "Baker Hughes"
      when /newmont\.com/
        "Newmont"
      when /glencore\.com/
        "Glencore"
      end
    end

    def self.call(job_offer_params, url)
      new(job_offer_params, url).call
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

    def initialize(job_offer_params, url)
      @job_offer_params = job_offer_params
      @url = url
    end

    def call
      job_offer = ExternalJobOffer.create!(params)
      Rails.logger.debug("The params are: #{params.inspect}")
      job_offer.order_placements.create!(paid_on: params[:options][:explanation].blank? ? Time.current : nil)
      job_offer.job_offer_actions.create!(action_type: JobOfferAction::CREATED_TYPE,
        valid_till: Time.current + Voucher.default_offer_duration)
    end

    private

    def params
      return @params if defined? @params
      params_ = job_offer_params.is_a?(Hash) ? job_offer_params : JSON.parse(job_offer_params)
      params_.merge!(employer: self.class.employer, application_destination: url,
        overcategory: JobOffer::CATEGORIES.overcategory_for(job_offer_params["category"]))
      known_company_name = self.class.company_name(url)
      if known_company_name.present?
        params_["company_name"] = known_company_name
      end
      params_[:options] ||= {}
      params_[:options][:explanation] = params_.delete("explanation")

      @params = params_
    end

    attr_reader :job_offer_params, :url
  end
end
