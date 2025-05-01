class ConfirmationsController < ApplicationController
  def confirm
    Registrations::ConfirmEmailService.call!(params[:token])
    flash[:notice] = "Email confirmed successfully."
    redirect_to root_path
  rescue Registrations::ConfirmEmailService::ConfirmationError => e
    flash[:alert] = e.message
    redirect_to root_path
  end

  def resend
    Registrations::SendConfirmationEmailService.call!(params[:email])
    flash[:notice] = "Confirmation email resent."
    redirect_to root_path
  rescue Registrations::SendConfirmationEmailService::ResendConfirmationError => e
    flash[:alert] = e.message
    redirect_to root_path
  end
end
