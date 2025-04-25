class CreateJobOffers < ActiveRecord::Migration[8.0]
  def change
    create_table :job_offers, id: :uuid do |t|
      t.string :title
      t.string :location
      t.text :description
      t.string :category
      t.boolean :apply_with_job_board
      t.boolean :is_featured
      t.boolean :is_approved, default: false, null: false
      t.references :employer, null: false, foreign_key: true

      t.timestamps
    end
  end
end
