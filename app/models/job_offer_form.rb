class JobOfferForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations

  attribute :voucher_code, :string

  attribute :title, :string
  attribute :company_name, :string

  attribute :email, :string
  attribute :email_confirmation, :string

  attribute :category, :string

  attribute :region, :string
  attribute :subregion, :string

  attribute :description, :string

  attribute :terms_and_conditions, :boolean

  attribute :application_type, :string

  attribute :application_destination, :string

  attr_accessor :logo

  validates_acceptance_of :terms_and_conditions, accept: [true, "y", "yes"]
  validates :description, presence: true, length: {maximum: 15_000}
  validates :title, presence: true, length: {maximum: 255}
  validates :company_name, presence: true, length: {maximum: 255}
  validates :email, presence: true,
    format: {with: /\A.+@.+\z/i, message: "must look like an email"},
    confirmation: {case_sensitive: false},
    length: {maximum: 255}

  validates :category, inclusion: {in: JobOffer::CATEGORIES.categories_names}
  validates :application_type, presence: true, inclusion: {in: JobOffer::APPLICATION_TYPES}
  validates :application_destination, presence: true, length: {maximum: 600}

  validates :region, inclusion: {in: JobOffer::HIGHLIGHTED_REGIONS + JobOffer::REGIONS}
  validates :subregion, {length: {maximum: 255}}

  validate :logo_type_and_size
  validate :voucher_code_check

  validate :employer_check
  # Include attr_accessor attributes in attribute_names
  def self.attribute_names
    super + ["logo"]
  end

  def self.from_job_offer(job_offer)
    new.tap do |instance|
      JobOffer.attribute_names.each { |name| instance.send("#{name}=", job_offer.send(name)) if job_offer.respond_to?(name) && instance.respond_to?("#{name}=") }
      instance.valid?
    end
  end

  def initialize(attributes = {})
    super
    @price = nil
  end

  def validate_application_destination
    return if application_destination.blank?
    if application_type == JobOffer::APPLICATION_TYPE_EMAIL
      unless /\A.+@.+\z/i.match?(application_destination)
        errors.add(:application_destination, "must be a valid email address")
      end
    elsif application_type == JobOffer::APPLICATION_TYPE_LINK
      unless /\A#{URI::RFC2396_PARSER.make_regexp(%w[http https])}\z/.match?(application_destination)
        errors.add(:application_destination, "must be a valid URL")
      end
    else
      errors.add(:application_type, "is not supported")
    end
  end

  def email=(value)
    super(value.to_s.strip.downcase)
  end

  def application_destination=(value)
    super(value.to_s.strip.downcase)
  end

  def employer_check
    return unless email.present?
    employer = Employer.find_by(email: email.strip)
    return if employer.nil?

    errors.add(:email, "is locked") if employer.locked_at.present?
    errors.add(:email, "has invalid domain") if Registrations::BlockedDomainsService.on_list?(employer.email)
    if employer.confirmation_sent_at && employer.confirmed_at.blank? # second to check if email was sent
      errors.add(:email, "is not confirmed yet. Check your mailbox for email or resend the confirmation email <a href=\"#\" onclick=\"event.preventDefault(); Turbo.visit('/confirm_email')\"><b>HERE</b></a>".html_safe)
    end
  end

  def logo_type_and_size
    return unless logo
    unless logo.respond_to?(:content_type) &&
        logo.content_type.start_with?("image/")
      errors.add(:logo, "must be an image file")
    end
    if logo.size > 1.megabyte
      errors.add(:logo, "should be smaller than 1 MB")
    end
  end

  def voucher_code_check
    voucher_code_ = voucher_code.strip if voucher_code
    return if voucher_code_.blank?
    voucher = Voucher.find_by(code: voucher_code_)
    if voucher.nil? || !voucher.can_apply?(self)
      reset_price
      errors.add(:voucher_code, "is not valid or disabled")
    else
      voucher.soft_apply(self)
    end
  end

  attr_writer :price

  def price
    @price ||= Voucher.default_price
  end

  def reset_price
    @price = Voucher.default_price
  end

  def submit # returns redirect_url
    return false unless valid?
    JobOffers::Submit.call!(info: self)
  end

  def voucher
    return Voucher.default_voucher if voucher_code.blank?
    Voucher.find_by(code: voucher_code.strip)
  end

  def voucher_placeholder
    return if voucher_code.blank?
    return if voucher_code == Voucher::DEFAULT_CODE

    voucher_code
  end
end
