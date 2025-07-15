class AddSlugToJobOffer < ActiveRecord::Migration[8.0]
  def change
    add_column :job_offers, :slug, :string
    add_index :job_offers, :slug, unique: true
  end
end
