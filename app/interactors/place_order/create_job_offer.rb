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
        overcategory: JobOffer::CATEGORIES.overcategory_for(category),
        terms_and_conditions:,
        application_type:,
        application_destination: application_dest
      )
      context.job_offer.logo.attach(logo) if logo.present?
    end

    delegate :employer, to: :context
    delegate(*JobOfferForm.attribute_names, to: :"context.info")
    delegate "voucher", "logo", "application_type", "application_destination", to: :"context.info"

    private

    def application_dest
      (application_type == JobOffer::APPLICATION_TYPE_LINK) ? with_utm_source : application_destination
    end

    def with_utm_source
      uri = URI.parse(application_destination)
      params = URI.decode_www_form(uri.query || "")

      # Remove existing utm_source parameter if it exists
      params.reject! { |key, _| key == "utm_source" }

      # Add the new utm_source parameter
      params << ["utm_source", ENV["RAILS_WEB_URL"]]

      uri.query = URI.encode_www_form(params)
      uri.to_s
    rescue URI::InvalidURIError => e
      Rails.logger.error("Invalid URI in job offer placement flow: #{application_destination} - #{e.message}")
      application_destination
    end
  end
end
