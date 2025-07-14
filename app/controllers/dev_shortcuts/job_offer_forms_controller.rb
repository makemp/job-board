module DevShortcuts
  class JobOfferFormsController < ApplicationController
    def new
      email = Faker::Internet.unique.email
      redirect_to new_job_offer_forms_path(job_offer_form: {email: email, email_confirmation: email,
                                                            company_name: Faker::Company.name,
                                                            title: Faker::Job.title,
                                                            category: JobOffer::CATEGORIES.sample,
                                                            region: JobOffer::REGIONS.sample,
                                                            description: Faker::Lorem.paragraph})
    end
  end
end
