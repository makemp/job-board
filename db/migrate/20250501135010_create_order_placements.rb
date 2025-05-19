class CreateOrderPlacements < ActiveRecord::Migration[8.0]
  def change
    create_table :order_placements do |t|
      t.boolean :free_order, default: false, null: false
      t.datetime :paid_at
      t.integer :price
      t.references :job_offer, null: false, foreign_key: true, type: :ulid
      t.string :voucher_code, null: false, default: Voucher::DEFAULT_CODE
      t.boolean :ready_to_be_placed, default: false
      t.timestamps
    end
  end
end
