require "rails_helper"

RSpec.describe "job_offers/index", type: :feature do
  after(:all) do
    ActiveRecord::Tasks::DatabaseTasks.truncate_all
  end

  before(:all) do
    Voucher.create!(code: Voucher::DEFAULT_CODE, options: {price: 299})
    FreeVoucher.create!(code: "FREE", options: {price: 0})
    Voucher.create!(enabled_till: 3.days.ago, code: "DISCOUNT", options: {price: 199})

    owl_labs = create(:employer, display_name: "Owl Drills",
      email: "owl@owldrills.com",
      password: "Password1!",
      confirmed_at: 1.day.ago)
    pelican_studios = create(:employer, display_name: "Pelican Studio Cranes",
      email: "john@pelican-studio-cranes.com",
      password: "Password1!",
      confirmed_at: 12.days.ago)
    dis_man = create(:employer, display_name: "Dis Man Hammer",
      email: "dis@dismanhammer.com",
      password: "Password1!",
      confirmed_at: 4.days.ago)

    employers = [owl_labs, pelican_studios, dis_man]
    titles = ["Digger", "Geologist", "Rock Developer", "Miner"]
    descriptions = ["Lorem ipsum dolor sit ament"]

    employers.each do |employer|
      employer.logo.attach(io: File.open(Rails.root.join("app/assets/images/dev_logos", "#{employer.display_name}.png")),
        filename: "logo.png")
    end
    id = 0

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
                company_name: employer.display_name,
                title: title,
                location: region,
                employer: employer,
                category: category,
                description: description
              )
              job.update_column(:id, id += 1)

              job.update_column(:created_at, (t_index + index).days.ago)
            end
          end
        end
      end
    end
  end

  before do
    Employer.all.each do |employer|
      if employer.logo.attached?
        allow_any_instance_of(ActionView::Helpers::AssetTagHelper)
          .to receive(:image_tag)
          .with(have_attributes(blob: employer.logo.blob), anything)
          .and_return('<img src="/assets/rails_logo_placeholder.png" />')
      end
    end
  end

  context "while visiting root page at the first time" do
    it do
      visit "/"
      expect(page).to match_snapshot("root_page")
    end
  end

  context "when visiting job offers index and changing the page" do
    it do
      visit "/"
      all("a", text: "2").first.click
      expect(page).to match_snapshot("root_page_page_2")
    end
  end
end
