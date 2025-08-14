class Admin::ExternalOffersController < ApplicationController
  before_action :authenticate_admin!
  skip_before_action :show_impersonation_notice

  def create
    url = params[:url]
    html = params[:html]

    if url.blank? || html.blank?
      redirect_to admin_dashboard_path, alert: "URL and HTML content are required"
      return
    end

    # Here you can add logic to save the external offer
    # For now, we'll just show a success message
    redirect_to admin_dashboard_path, notice: "External offer created successfully"
  end
end
