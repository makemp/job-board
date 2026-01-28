# == Schema Information
#
# Table name: job_offers
#
#  id                      :ulid             not null, primary key
#  application_destination :string
#  application_type        :string
#  approved                :boolean          default(FALSE), not null
#  category                :string
#  company_name            :string
#  custom_logo             :text
#  expired_manually        :datetime
#  expired_on              :datetime
#  offer_type              :string
#  options                 :json
#  overcategory            :string
#  region                  :string
#  slug                    :string
#  subregion               :string
#  terms_and_conditions    :boolean          default(FALSE)
#  title                   :string
#  type                    :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  employer_id             :ulid             not null
#
# Indexes
#
#  idx_job_offers_expired_on        (expired_on)
#  index_job_offers_on_employer_id  (employer_id)
#  index_job_offers_on_slug         (slug) UNIQUE
#
# Foreign Keys
#
#  employer_id  (employer_id => users.id)
#
FactoryBot.define do
  factory :job_offer do
    title { "Sample Job Title" }
    company_name { "Sample Company" }
    region { JobOffer::REGIONS.sample }
    overcategory { JobOffer::CATEGORIES.overcategories_names.sample }
    category { |job_offer| JobOffer::CATEGORIES.categories_for(job_offer.overcategory).sample }
    approved { true }
    association :employer
  end
end
