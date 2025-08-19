class CreateJobAlertFilters < ActiveRecord::Migration[8.0]
  def change
    create_table :job_alert_filters, id: :ulid, default: -> { "ulid()" } do |t|
      t.references :job_alert, null: false, foreign_key: true, type: :ulid
      t.string :category
      t.string :region
      t.string :frequency
      t.boolean :active
      t.string :confirmation_token
      t.datetime :confirmed_at
      t.boolean :enabled

      t.timestamps
    end
  end
end
