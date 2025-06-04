class AddStripeSessionIdToOrderPlacements < ActiveRecord::Migration[8.0]
  def change
    add_column :order_placements, :stripe_session_id, :string
    add_index :order_placements, :stripe_session_id, unique: true
  end
end
