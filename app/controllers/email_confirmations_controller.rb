class EmailConfirmationsController < ApplicationController
  MSG = "If email exists and is not confirmed, a confirmation email will be sent to it. Check your inbox.".freeze
  def email_confirmed
    job_offer = Registrations::ConfirmEmailService.call!(params[:token])
    flash[:notice] = "Email confirmed successfully. Your job offer is now visible!"
    redirect_to job_offer_path(job_offer, success: true)
  rescue Registrations::ConfirmEmailService::ConfirmationError => e
    flash[:alert] = e.message
    redirect_to root_path
  end

  def confirm_email
  end

  def first_confirmation_email_sent
  end

  def resend_confirmation_email
    email = resend_confirmation_params[:email]
    Registrations::SendConfirmationEmailService.call!(email)
    flash[:notice] = MSG
    redirect_to confirm_email_path
  rescue Registrations::SendConfirmationEmailService::ResendConfirmationError => e
    flash[:notice] = MSG
    Rails.logger.warn("Resend confirmation error: #{e.message} for email: #{email}")
    redirect_to confirm_email_path
  end

  private

  def resend_confirmation_params
    params.permit(:email)
  end
end
