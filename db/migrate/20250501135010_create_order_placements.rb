class CreateOrderPlacements < ActiveRecord::Migration[8.0]
  def change
    create_table :order_placements do |t|
      t.boolean :free_order, default: false, null: false
      t.datetime :paid_at
      t.integer :price, null: false
      t.references :job_offer, null: false, foreign_key: true, type: :uuid
      t.string :voucher_code, null: false, default: Voucher::DEFAULT_CODE
      t.timestamps
    end
  end
end
