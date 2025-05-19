class ApplicationController < ActionController::Base
  before_action :assign_flash_from_query

  include Pagy::Backend
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  private

  def assign_flash_from_query
    flash[:notice] = params.delete(:flash_notice) if params[:flash_notice].present?
  end
end
