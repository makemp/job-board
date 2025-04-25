class CreateVouchers < ActiveRecord::Migration[8.0]
  def change
    enable_extension "hstore"

    create_table :vouchers do |t|
      t.string :code, null: false
      t.hstore :options, default: {}
      t.boolean :enable, default: false, null: false
      t.string :type
      t.timestamps
    end
  end
end
