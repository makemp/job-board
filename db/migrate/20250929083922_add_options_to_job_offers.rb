class AddOptionsToJobOffers < ActiveRecord::Migration[8.0]
  def change
    add_column :job_offers, :options, :json
  end
end
