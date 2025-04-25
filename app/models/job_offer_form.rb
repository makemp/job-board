class JobOfferForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations

  attribute :voucher_code, :string

  attribute :title, :string

  attribute :email, :string
  attribute :email_confirmation, :string

  attribute :category, :string

  attribute :location, :string

  attribute :description, :string

  attr_accessor :logo

  validates :description, presence: true
  validates :title, presence: true
  validates :email, presence: true,
    format: {with: /@/, message: "must look like an email"},
    confirmation: {case_sensitive: false}

  validates :category, inclusion: {in: JobOffer::CATEGORIES}

  validates :location, inclusion: {in: JobOffer::HIGHLIGHTED_REGIONS + JobOffer::REGIONS}

  validate :logo_type_and_size
  validate :voucher_code_check

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
    voucher_code = voucher_code.strip if voucher_code
    return if voucher_code.blank?
    voucher = Voucher.find_by(code: voucher_code)
    if voucher.nil?
      errors.add(:voucher_code, "is not valid")
    elsif !voucher.enable
      errors.add(:voucher_code, "is not enabled")
    end
  end

  def price
    @price ||= Voucher.default_price
  end

  attr_writer :price
end
