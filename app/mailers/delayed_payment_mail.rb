class DelayedPaymentMail < ApplicationMailer
  def paid_intent_succeeded(order_placement)
    @order_placement = order_placement
    @employer = order_placement.employer
    @job_offer = order_placement.orderable
    @job_offer_url = job_offer_url(@job_offer)

    mail(
      to: @employer.email,
      subject: "Payment Confirmed - Your Job Offer is Now Live!"
    )
  end

  def paid_intent_created(order_placement, data)
    data = data.with_indifferent_access
    Rails.logger.info("Paid intent created data: #{data.inspect}")
    @order_placement = order_placement
    @employer = order_placement.employer
    @job_offer_title = order_placement.orderable.title
    # example "https://payments.stripe.com/bank_transfers/instructions/test_YWNjdF8xUlFRZXRRNzZ0dWw3WEpJLF9URDJhSk4yRGhUMERjVERIcjNLbzhSSUI5YWVWMTBG0100sWL4b8qV"
    @instructions_url = data["next_action"]["display_bank_transfer_instructions"]["hosted_instructions_url"]

    mail(
      to: @employer.email,
      subject: "Payment Required - Action Required to Publish Your Job Offer"
    )
  end
end

{next_action:
  {display_bank_transfer_instructions:
     {amount_remaining: 7900, currency: "gbp",
      financial_addresses:
        [{sort_code: {account_holder_address: {city: "London", country: "GB", line1: "9th Floor, 107 Cheapside", line2: nil, postal_code: "EC2V6DN", state: "London"}, account_holder_name: "Drill Jobs sandbox", account_number: "19866865", bank_address: {city: "London", country: "GB", line1: "1 CHURCHILL PLACE", line2: nil, postal_code: "E14 5HP", state: "England"}, sort_code: "108800"}, supported_networks: ["bacs", "fps"], type: "sort_code"}],
      hosted_instructions_url: "https://payments.stripe.com/bank_transfers/instructions/test_YWNjdF8xUlFRZXRRNzZ0dWw3WEpJLF9URDVNWGpsZ0JBNmpvc0ZkZnFkaEpoV3JFMU8zMklZ0100yleWTWQd", reference: "QV9XQTDWZ8HR", type: "gb_bank_transfer"}}}
