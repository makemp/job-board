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
      render :index, status: :unprocessable_conten
      return
    end

    if @contact.valid?
      ContactMailer.contact_email(@contact).deliver_now
      redirect_to contact_path, notice: "Your message has been sent."
    else
      render :index, status: :unprocessable_conten
    end
  end

  private

  def contact_params
    params.require(:contact).permit(:email, :message, :anti_bot_token, :anti_bot_seed, :anti_bot_timestamp, :given_name, :family_name)
  end
end
