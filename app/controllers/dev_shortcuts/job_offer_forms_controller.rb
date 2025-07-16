module DevShortcuts
  class JobOfferFormsController < ApplicationController
    def new
      email = Faker::Internet.unique.email
      cats = JobOffer::CATEGORIES.sample
      redirect_to new_job_offer_forms_path(job_offer_form: {email: email, email_confirmation: email,
                                                            company_name: Faker::Company.name,
                                                            title: Faker::Job.title,
                                                            category: cats.last,
                                                            overcategory: cats.first,
                                                            region: JobOffer::REGIONS.sample,
                                                            description: Faker::Lorem.paragraph})
    end
  end
end
