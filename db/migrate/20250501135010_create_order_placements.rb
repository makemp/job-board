class CreateOrderPlacements < ActiveRecord::Migration[8.0]
  def change
    create_table :order_placements, id: :ulid, default: -> { "ulid()" } do |t|
      t.boolean :free_order, default: false, null: false
      t.datetime :paid_at
      t.integer :price
      t.references :job_offer, null: true, foreign_key: true, type: :ulid
      t.references :special_offer, null: true, foreign_key: true, type: :ulid
      t.string :voucher_code, null: false, default: Voucher::DEFAULT_CODE
      t.boolean :ready_to_be_placed, default: false
      t.json :job_offer_params, default: {}
      t.timestamps
    end
  end
end
