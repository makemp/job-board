class ContactController < ApplicationController
  before_action -> { handle_check_hashcash("contact-form") }, only: [:create]
  def index
    @contact = Contact.new
  end

  def create
    @contact = Contact.new(contact_params)
    if @contact.valid?
      ContactMailer.contact_email(@contact).deliver_now
      redirect_to contact_path, notice: "Your message has been sent."
    else
      render :index, status: :unprocessable_entity
    end
  end

  private

  def contact_params
    params.require(:contact).permit(:email, :message)
  end
end
