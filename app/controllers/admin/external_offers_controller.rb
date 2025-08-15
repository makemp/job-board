class Admin::ExternalOffersController < ApplicationController
  before_action :authenticate_admin!
  skip_before_action :show_impersonation_notice

  def create
    url = params[:url]
    html = params[:html]
    json = params[:json]

    if json.present?
      JobOffers::CreateExternalJobOffer.call(json)
      redirect_to admin_dashboard_path + "#add-offer", notice: "External offer created successfully" and return
    end

    if url.blank? || html.blank?
      redirect_to admin_dashboard_path + "#add-offer", alert: "URL and HTML content are required. Or JSON field"
      return
    end

    JobOffers::CreateExternalJobOffer.call(Ai::ExternalJobOfferService.call(url, html))
    redirect_to admin_dashboard_path + "#add-offer", notice: "External offer created successfully"
  end
end
