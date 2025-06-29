module Employers
  class DashboardController < ApplicationController
    before_action :authenticate_employer!

    def index
      # dashboard landing
    end

    def update_password
      if current_employer.update(password_params)
        bypass_sign_in(current_employer)
        redirect_to employers_dashboard_path, notice: "Password updated successfully."
      else
        flash.now[:alert] = current_employer.errors.full_messages.to_sentence
        render :index
      end
    end

    def update_billing
      detail = current_employer.billing_detail || current_employer.build_billing_detail
      if detail.update(billing_params)
        redirect_to employers_dashboard_path, notice: "Billing details saved."
      else
        flash.now[:alert] = detail.errors.full_messages.to_sentence
        render :index
      end
    end

    def close_account
      current_employer.destroy
      redirect_to root_path, notice: "Your account has been closed."
    end

    def update_details
      if current_employer.update(details_params)
        redirect_to employers_dashboard_path, notice: "Details updated successfully."
      else
        flash.now[:alert] = current_employer.errors.full_messages.to_sentence
        render :index
      end
    end

    private

    def password_params
      params.require(:employer).permit(:password, :password_confirmation)
    end

    def billing_params
      params.require(:billing_detail).permit(:company_name, :tax_id, :address, :city, :zip, :country)
    end

    def details_params
      params.require(:employer).permit(:company_name, :logo)
    end
  end
end
