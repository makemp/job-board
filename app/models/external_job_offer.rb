class ExternalJobOffer < JobOffer
  validates :application_destination, presence: true, uniqueness: true

  before_create :generate_svg_logo

  def employer_company_name
    the_company_name
  end

  def logo
    @logo ||= SvgLogoDecorator.new(custom_logo)
  end

  private

  def generate_svg_logo
    self.custom_logo = SvgLogoGenerator.generate_random_logo("External Job Offer")
  end
end
