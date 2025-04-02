# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
ActiveRecord::Tasks::DatabaseTasks.truncate_all


owl_labs = Employer.create!(display_name: "Owl Labs",
  email: "owl@labs.com",
  password: "Password1!",
  confirmed_at: 1.day.ago,
  approved_at: 1.day.ago)
pelican_studios = Employer.create!(display_name: "Pelican Studios",
  email: "john@pelican-studios.com",
  password: "Password1!",
  confirmed_at: 12.days.ago,
  approved_at: 3.days.ago)
dis_man = Employer.create!(display_name: "Dis Man",
  email: "dis@man.com",
  password: "Password1!",
  confirmed_at: 4.days.ago,
  approved_at: 2.days.ago,
  disabled_at: 1.day.ago)

employers = [owl_labs, pelican_studios, dis_man]
titles = ['Digger', 'Geologist', 'Rock Developer', 'Miner']
descriptions = ['Lorem ipsum dolor sit ament']


employers.each do |employer|
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
