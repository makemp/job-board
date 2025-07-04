class CreateJobOfferActions < ActiveRecord::Migration[8.0]
  def change
    create_table :job_offer_actions, id: :ulid do |t|
      t.string :type
      t.datetime :expires_on, null: false
      t.references :job_offer, null: false, foreign_key: true, type: :ulid

      t.timestamps
    end
  end
end
