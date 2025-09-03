class Admin::ExternalOffersController < ApplicationController
  before_action :authenticate_admin!
  skip_before_action :show_impersonation_notice

  def check_url
    url = params[:url]

    if url.blank?
      render json: {exists: false, message: ""}
      return
    end

    existing_offer = ExternalJobOffer.find_by(application_destination: url)

    if existing_offer
      render json: {
        exists: true,
        message: "An external offer with this URL already exists: \"#{existing_offer.title}\" at #{existing_offer.the_company_name}",
        offer: {
          title: existing_offer.title,
          company: existing_offer.the_company_name,
          created_at: existing_offer.created_at.strftime("%B %d, %Y")
        }
      }
    else
      render json: {exists: false, message: ""}
    end
  end

  def create
    url = params[:url]
    html = params[:html]
    json = params[:json]

    begin
      if json.present? && url.present?
        JobOffers::CreateExternalJobOffer.call(json, url)
        respond_to do |format|
          format.html { redirect_to admin_dashboard_path + "#add-offer", notice: "External offer created successfully" }
          format.turbo_stream { render turbo_stream: turbo_stream.replace("flash-messages", partial: "shared/flash", locals: {message: "External offer created successfully", type: "notice"}) }
        end
        return
      end

      if url.blank? || html.blank?
        respond_to do |format|
          format.html { redirect_to admin_dashboard_path + "#add-offer", alert: "URL and HTML content are required. Or JSON field and URL" }
          format.turbo_stream { render turbo_stream: turbo_stream.replace("flash-messages", partial: "shared/flash", locals: {message: "URL and HTML content are required. Or JSON field and URL", type: "alert"}) }
        end
        return
      end

      JobOffers::CreateExternalJobOffer.call(Ai::ExternalJobOfferService.call(html), url)
      respond_to do |format|
        format.html { redirect_to admin_dashboard_path + "#add-offer", notice: "External offer created successfully" }
        format.turbo_stream { render turbo_stream: turbo_stream.replace("flash-messages", partial: "shared/flash", locals: {message: "External offer created successfully", type: "notice"}) }
      end
    rescue => e
      respond_to do |format|
        format.html { redirect_to admin_dashboard_path + "#add-offer", alert: "Error creating external offer: #{e.message}" }
        format.turbo_stream { render turbo_stream: turbo_stream.replace("flash-messages", partial: "shared/flash", locals: {message: "Error creating external offer: #{e.message}", type: "alert"}) }
      end
    end
  end
end
