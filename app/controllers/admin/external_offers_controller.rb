class Admin::ExternalOffersController < ApplicationController
  before_action :authenticate_admin!
  skip_before_action :show_impersonation_notice

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
