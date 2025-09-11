class AddLogoToJobOffers < ActiveRecord::Migration[7.0]
  def change
    add_column :job_offers, :custom_logo, :text
  end
end
