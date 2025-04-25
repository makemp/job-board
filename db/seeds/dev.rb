ActiveRecord::Tasks::DatabaseTasks.truncate_all

Voucher.create!(enable: true, code: Voucher::DEFAULT_CODE, options: {price: 299})
FreeVoucher.create!(enable: true, code: "FREE", options: {price: 0})
Voucher.create!(enable: false, code: "DISCOUNT", options: {price: 199})

owl_labs = Employer.create!(display_name: "Owl Drills",
  email: "owl@owldrills.com",
  password: "Password1!",
  confirmed_at: 1.day.ago,
  approved_at: 1.day.ago)
pelican_studios = Employer.create!(display_name: "Pelican Studio Cranes",
  email: "john@pelican-studio-cranes.com",
  password: "Password1!",
  confirmed_at: 12.days.ago,
  approved_at: 3.days.ago)
dis_man = Employer.create!(display_name: "Dis Man Hammer",
  email: "dis@dismanhammer.com",
  password: "Password1!",
  confirmed_at: 4.days.ago,
  approved_at: 2.days.ago)

employers = [owl_labs, pelican_studios, dis_man]
titles = ["Digger", "Geologist", "Rock Developer", "Miner"]
descriptions = ["Lorem ipsum dolor sit ament"]

(JobOffer::HIGHLIGHTED_REGIONS + JobOffer::REGIONS.sample(5)).each do |region|
  employers.each do |employer|
    employer.logo.attach(io: File.open(Rails.root.join("app/assets/images/dev_logos", "#{employer.display_name}.png")),
      filename: "logo.png")
    titles.each do |title|
      descriptions.each do |description|
        JobOffer::CATEGORIES.each do |category|
          job = JobOffer.create!(
            title: title,
            location: region,
            description: description,
            employer_id: employer.id,
            category: category
          )
          job.update_column(:created_at, rand(1..10).days.ago)
        end
      end
    end
  end
end
