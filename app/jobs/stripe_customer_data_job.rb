# This job takes stripe data from webhook and matches it with order placement of given employer

class StripeCustomerDataJob < ApplicationJob
  queue_as :default

  def perform(event_type, data)
    data = data.with_indifferent_access
    customer_id = data[:customer] || data[:id]
    customer = Employer.find_by(stripe_customer_id: customer_id)
    order_placement = customer.latest_order_placement
    order_placement.update!(stripe_payload: order_placement.stripe_payload.merge({event_type => data.deep_symbolize_keys}))
  rescue => e
    Rails.logger.error "StripeCustomerDataJob processing error #{event_type} data: #{data}, error: #{e.message}"
    raise e
  end

  #  Enqueued StripeCustomerDataJob (Job ID: ba06120d-403a-467f-8403-54f16e74785c) to SolidQueue(default) at 2025-06-20 23:31:33 UTC with arguments: "customer.tax_id.updated", {id: "txi_1RcEN4Q76tul7XJI7TZIxJm8", object: "tax_id", country: "GB", created: 1750462162, customer: "cus_SXIzz5Ph3Kekkr", livemode: false, owner: {customer: "cus_SXIzz5Ph3Kekkr", type: "customer"}, type: "gb_vat", value: "GB123456789", verification: {status: "verified", verified_address: "123 TEST STREET", verified_name: "TEST"}}
end
