class CreateSpecialOffers < ActiveRecord::Migration[8.0]
  def change
    create_table :special_offers, id: :ulid, default: -> { "ulid()" } do |t|
      t.string :name, null: false
      t.text :description
      t.integer :number_of_vouchers, null: false
      t.integer :price, null: false
      t.timestamps
    end
  end
end