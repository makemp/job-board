# JSON structure:

# {
#    company: 'Company Name',
#    title: 'Job Title',
#    location: 'USA',
#    application_destination: 'https://example.com/link_to_external_offer'
#    category: 'Engineering',
# }

class ExternalJobOffer < JobOffer
  def self.employer
    return @employer if @employer.present?

    # Create or find the employer for external job offers
    # This is a placeholder; you can customize the company_name and email as needed
    @employer = Employer.find_or_create_by!(company_name: "External Job Offers",
      email: "external@external.com")
    @employer.update(confirmed_at: Time.current)

    @employer.reload
  end

  def self.from_hash(hsh)
    hsh.stringify_keys!
    job_offer = ExternalJobOffer.create!(
      {
        application_type: hsh["company"], # yes, we are using this as a company name
        title: hsh["title"],
        region: hsh["region"],
        application_destination: hsh["application_destination"],
        category: hsh["category"],
        overcategory: JobOffer::CATEGORIES.overcategory_for(hsh["category"]),
        employer: employer
      }
    )
    job_offer.order_placements.create!(paid_on: Time.current)
    job_offer.job_offer_actions.create!(action_type: JobOfferAction::CREATED_TYPE,
      valid_till: Time.current + Voucher.default_offer_duration)
  end

  def employer_company_name
    the_company_name
  end
end
