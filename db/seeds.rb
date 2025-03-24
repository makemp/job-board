# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

owl_labs = Employer.create!(display_name: "Owl Labs",
  email: "owl@labs.com",
  password: "password",
  confirmed_at: 1.day.ago,
  approved_at: 1.day.ago)
pelican_studios = Employer.create!(display_name: "Pelican Studios",
  email: "john@pelican-studios.com",
  password: "password",
  confirmed_at: 12.days.ago,
  approved_at: 3.days.ago)
dis_man = Employer.create!(display_name: "Dis Man",
  email: "dis@man.com",
  password: "password",
  confirmed_at: 4.days.ago,
  approved_at: 2.days.ago,
  disabled_at: 1.day.ago)

owl_labs.jobs.create!(title: "Digger", location: "UAE", salary: "90000 AED/month", description: "Digging stuff")
owl_labs.jobs.create!(title: "Geologist", location: "UAE", salary: "120000 AED/month", description: "Finding rocks")

pelican_studios.jobs.create!(title: "Rock Developer", location: "USA", salary: "120000 USD/year", description: "Developing stuff")

dis_man.jobs.create!(title: "Miner", location: "Canada", salary: "120000 CUSD/year", description: "Mining stuff")
