class AddCompanyNameToJobOffers < ActiveRecord::Migration[6.1]
  def change
    add_column :job_offers, :company_name, :string
  end
end
