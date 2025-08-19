class CreateJobAlerts < ActiveRecord::Migration[8.0]
  def change
    create_table :job_alerts, id: :ulid, default: -> { "ulid()" } do |t|
      t.references :user, null: true, foreign_key: true, type: :ulid
      t.string :email
      t.string :management_token

      t.timestamps
    end
  end
end
