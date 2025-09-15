class Contact
  include ActiveModel::Model

  attr_accessor :email, :message

  validates :email, presence: true, format: {with: URI::MailTo::EMAIL_REGEXP}
  validates :message, presence: true

  def to_h
    {
      email:,
      message:
    }
  end
end
