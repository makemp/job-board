class CreateJobOffers < ActiveRecord::Migration[8.0]
  def change
    create_table :job_offers, id: :ulid, default: -> { "ulid()" } do |t|
      t.string :title
      t.string :region
      t.string :subregion
      t.string :overcategory
      t.string :category
      t.string :application_type
      t.string :application_destination
      t.datetime :expired_on
      t.datetime :expired_manually
      t.boolean :approved, default: false, null: false
      t.boolean :terms_and_conditions, default: false
      t.string :type
      t.string :offer_type # e.g., Mining, Drilling, Both, Other - at the beginning only for external offers.
      t.references :employer, null: false, foreign_key: {to_table: :users}, type: :ulid

      t.timestamps
    end
  end
end
