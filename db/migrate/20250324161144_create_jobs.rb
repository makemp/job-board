class CreateJobs < ActiveRecord::Migration[8.0]
  def change
    create_table :jobs, id: :uuid do |t|
      t.string :title
      t.string :location
      t.text :description
      t.string :salary
      t.string :apply_url
      t.boolean :is_featured
      t.references :employer, null: false, foreign_key: true

      t.timestamps
    end
  end
end
