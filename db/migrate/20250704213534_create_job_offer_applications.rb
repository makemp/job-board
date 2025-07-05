class CreateJobOfferApplications < ActiveRecord::Migration[8.0]
  def change
    create_table :job_offer_applications, id: :ulid, default: -> { "ulid()" } do |t|
      t.references :job_offer, null: false, foreign_key: true, type: :ulid

      t.timestamps
    end
  end
end
