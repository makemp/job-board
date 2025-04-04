ActiveRecord::Tasks::DatabaseTasks.truncate_all

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

employers.each do |employer|
  employer.logo.attach(io: File.open(Rails.root.join("app/assets/images/dev_logos", "#{employer.display_name}.png")),
    filename: "logo.png")
  titles.each do |title|
    (Job::HIGHLIGHTED_REGIONS + Job::REGIONS.sample(5)).each do |region|
      descriptions.each do |description|
        Job::CATEGORIES.each do |category|
          Job.create!(
            title: title,
            location: region,
            description: description,
            employer_id: employer.id,
            category: category
          )
        end
      end
    end
  end
end
