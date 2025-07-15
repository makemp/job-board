class PurgeStripeDataOnOrderPlacement < ApplicationJob
  queue_as :low_priority

  def perform(order_placement_id)
    OrderPlacement.find(order_placement_id).update_column(:stripe_payload, {})
  end
end