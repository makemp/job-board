class ContactController < ApplicationController
  include AntiBot

  def index
    @contact = Contact.new
  end

  def create
    @contact = Contact.new(contact_params.slice(:email, :message))

    # Validate anti-bot token before processing the form
    unless valid_anti_bot_token?
      @contact.errors.add(:base, "Security validation failed. Please try again.")
      render :index, status: :unprocessable_content
      return
    end

    if @contact.valid?
      ContactMailer.contact_email(@contact.to_h).deliver_later
      redirect_to contact_path, notice: "Your message has been sent."
    else
      render :index, status: :unprocessable_content
    end
  end

  private

  def contact_params
    params.require(:contact).permit(:email, :message, :given_name, :family_name, :anti_bot_token, :anti_bot_seed, :anti_bot_timestamp)
  end

  def anti_bot_params
    params["contact"].slice(*AntiBot::FIELDS)
  end
end
