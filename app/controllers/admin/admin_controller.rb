class Admin::AdminController < ApplicationController
  before_action :authenticate_admin!
  # Skip impersonation notice for admin panel
  skip_before_action :show_impersonation_notice

  # Admin dashboard
  def index
    @employers = Employer.valid.order(:company_name)
    @external_job_offers = ExternalJobOffer.in_pending_queue
  end

  # Impersonate an employer
  def impersonate
    employer = Employer.find(params[:id])
    sign_in(employer)
    redirect_to employers_dashboard_path, notice: "Now viewing as #{employer.email}"
  end

  # Stop impersonating
  def stop_impersonating
    sign_out(current_employer)
    redirect_to admin_dashboard_path, notice: "Stopped impersonating and returned to admin panel"
  end
end
