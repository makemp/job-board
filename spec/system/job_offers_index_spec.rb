require "rails_helper"

RSpec.describe "job_offers/index", type: :feature, js: true, driver: :selenium_chrome do
  after(:all) do
    ActiveRecord::Tasks::DatabaseTasks.truncate_all
  end

  before(:all) do
    ActiveRecord::Tasks::DatabaseTasks.truncate_all
    Voucher.create!(code: Voucher::DEFAULT_CODE, options: {price: 299})
    FreeVoucher.create!(code: "FREE", options: {price: 0})
    Voucher.create!(enabled_till: 3.days.ago, code: "DISCOUNT", options: {price: 199})

    owl_labs = create(:employer, company_name: "Owl Drills",
      email: "owl@owldrills.com",
      password: "Password1!",
      confirmed_at: 1.day.ago)
    pelican_studios = create(:employer, company_name: "Pelican Studio Cranes",
      email: "john@pelican-studio-cranes.com",
      password: "Password1!",
      confirmed_at: 12.days.ago)
    dis_man = create(:employer, company_name: "Dis Man Hammer",
      email: "dis@dismanhammer.com",
      password: "Password1!",
      confirmed_at: 4.days.ago)

    employers = [owl_labs, pelican_studios, dis_man]
    titles = ["Digger", "Geologist", "Rock Developer", "Miner", "Driller", "Drilling Engineer", "Drilling Supervisor"]
    descriptions = ["Lorem ipsum dolor sit ament"]

    employers.each do |employer|
      employer.logo.attach(io: File.open(Rails.root.join("app/assets/images/dev_logos", "#{employer.company_name}.png")),
        filename: "logo.png")
    end

    ["Australia",
      "Canada",
      "USA",
      "UAE",
      "Chile", "Chad", "China", "Colombia", "Comoros", "Congo"].each do |region|
      employers.each do |employer|
        titles.each_with_index do |title, t_index|
          descriptions.each do |description|
            JobOffer::CATEGORIES.each_with_index do |category, index|
              job = JobOffer.create!(
                company_name: employer.company_name,
                title: title,
                location: region,
                employer: employer,
                category: category,
                description: description
              )

              job.update_column(:created_at, (t_index + index).days.ago)
            end
          end
        end
      end
    end
  end

  context "when visiting job offers index and changing the page and filter" do
    it do
      visit "/"
      match_snapshot!(page, "root_page")
      within("#pagination-top") do
        find("a", exact_text: "2", wait: 1).click
      end
      match_snapshot!(page, "root_page_page2")

      select "Drilling", from: "Category"
      match_snapshot!(page, "root_page_drilling")
      select "10", from: "Results per page"
      within("#pagination-top") do
        find("a", exact_text: "2", wait: 1).click
      end

      match_snapshot!(page, "root_page_drilling_page_2")
      select "Colombia", from: "Region"

      match_snapshot!(page, "root_page_colombia")
      within("#pagination-top") do
        find("a", exact_text: "2", wait: 1).click
      end

      match_snapshot!(page, "root_page_colombia_page_2")
      select "Colombia", from: "Region"
      select "Drilling", from: "Category"
      match_snapshot!(page, "root_page_colombia_drilling")
    end
  end
end
