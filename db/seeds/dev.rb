require "index_manager"

ActiveRecord::Tasks::DatabaseTasks.truncate_all

Voucher.create!(code: Voucher::DEFAULT_CODE, options: {price: 79, offer_duration: 60.days})
FreeVoucher.create!(code: "FREE", options: {price: 0, offer_duration: 15.days})
Voucher.create!(enabled_till: 3.days.ago, code: "DISCOUNT", options: {price: 199, offer_duration: 30.days})

owl_labs = Employer.create!(company_name: "Owl Drills",
  email: "owl@owldrills.com",
  password: "Password1!",
  confirmed_at: 1.day.ago)
pelican_studios = Employer.create!(company_name: "Pelican Studio Cranes",
  email: "john@pelican-studio-cranes.com",
  password: "Password1!",
  confirmed_at: 12.days.ago)
dis_man = Employer.create!(company_name: "Dis Man Hammer",
  email: "dis@dismanhammer.com",
  password: "Password1!",
  confirmed_at: 4.days.ago)

employers = [owl_labs, pelican_studios, dis_man]
titles = ["Digger", "Geologist", "Rock Developer", "Miner"]
descriptions = ["Lorem ipsum dolor sit ament"]

employers.each do |employer|
  employer.logo.attach(io: File.open(Rails.root.join("app/assets/images/dev_logos", "#{employer.company_name}.png")),
    filename: "logo.png")
end

(JobOffer::HIGHLIGHTED_REGIONS + JobOffer::REGIONS.sample(5)).each do |region|
  employers.each do |employer|
    titles.each do |title|
      descriptions.each do |description|
        JobOffer::CATEGORIES.overcategories_names.each do |overcategory|
          application_type = JobOffer::APPLICATION_TYPES.sample(1).first
          application_destination = if application_type == JobOffer::APPLICATION_TYPE_LINK
            Faker::Internet.url
          else
            Faker::Internet.email
          end

          job = JobOffer.create!(
            company_name: employer.company_name,
            title: title,
            region: region,
            subregion: [nil, Faker::Address.state].sample,
            employer: employer,
            overcategory: overcategory,
            category: JobOffer::CATEGORIES.categories_for(overcategory).sample,
            description: Faker::Lorem.sentences(number: 200).join("\n\n"),
            application_destination:,
            application_type:
          )

          job.order_placements << OrderPlacement.create!(paid_on: Time.current)
          job.job_offer_actions.create!(action_type: JobOfferAction::CREATED_TYPE,
            valid_till: Time.current + Voucher.default_offer_duration)

          job.recent_action.update_column(:created_at, rand(1..10).days.ago)
        end
      end
    end
  end
end

Admin.create!(email: "admin@admin.com", password: "Abcd1234!")

ExternalJobOffer.from_hash({
  company: "University of Colorado Denver",
  title: "IELTS USA Examiner",
  region: "USA",
  application_destination: "https://minejobs.com/job-details/?title=IELTS_USA_Examiner&id=6308502",
  category: "Human Resources & Training",
  overcategory: "Corporate & Support Services"
})
