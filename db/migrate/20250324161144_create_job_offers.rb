class CreateJobOffers < ActiveRecord::Migration[8.0]
  def change
    create_table :job_offers, id: :ulid, default: -> { "ulid()" } do |t|
      t.string :title
      t.string :location
      t.string :category
      t.string :application_type
      t.string :application_destination
      t.datetime :expires_on
      t.datetime :expires_manually
      t.boolean :featured
      t.boolean :approved, default: false, null: false
      t.boolean :terms_and_conditions, default: false
      t.references :employer, null: false, foreign_key: true, type: :ulid

      t.timestamps
    end
  end
end
