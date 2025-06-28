require "index_manager"

ActiveRecord::Tasks::DatabaseTasks.truncate_all

Voucher.create!(code: Voucher::DEFAULT_CODE, options: {price: 299, offer_duration: 30.days})
FreeVoucher.create!(code: "FREE", options: {price: 0, offer_duration: 30.days})
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
        JobOffer::CATEGORIES.each do |category|
          job = JobOffer.create!(
            company_name: employer.company_name,
            title: title,
            location: region,
            employer: employer,
            category: category,
            description: description,
            expires_on: 70.years.from_now
          )

          job.update_column(:created_at, rand(1..10).days.ago)
        end
      end
    end
  end
end
