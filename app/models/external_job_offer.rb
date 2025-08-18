class ExternalJobOffer < JobOffer
  validates :application_destination, presence: true, uniqueness: true
  def employer_company_name
    the_company_name
  end
end
