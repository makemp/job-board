class ApplicationController < ActionController::Base
  before_action :assign_flash_from_query

  include Pagy::Backend
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Add impersonation notification
  before_action :show_impersonation_notice

  private

  def assign_flash_from_query
    flash[:notice] = params.delete(:flash_notice) if params[:flash_notice].present?
  end

  def show_impersonation_notice
    if impersonating?
      flash[:impersonation] = "You are pretending to be #{current_employer.email}. #{view_context.button_to("Click here to stop pretending and back to admin panel", admin_stop_impersonating_employers_path, method: :delete, class: "underline")}"
    end
  end

  def impersonating?
    current_employer && current_admin
  end
end
