class CreateVouchers < ActiveRecord::Migration[8.0]
  def change
    enable_extension "hstore"

    create_table :vouchers, id: :ulid, default: -> { "generate_ulid()" } do |t|
      t.string :code, null: false
      t.hstore :options, default: {}
      t.datetime :enabled_till, default: Time.current + 200.years
      t.string :type
      t.timestamps
    end
  end
end
