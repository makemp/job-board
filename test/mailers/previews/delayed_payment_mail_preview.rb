class DelayedPaymentMailPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/delayed_payment_mail/paid_intent_succeeded
  def paid_intent_succeeded
    order_placement = create_sample_order_placement
    DelayedPaymentMail.paid_intent_succeeded(order_placement)
  end

  # Preview this email at http://localhost:3000/rails/mailers/delayed_payment_mail/paid_intent_created
  def paid_intent_created
    order_placement = create_sample_order_placement_unpaid
    data = create_sample_stripe_data
    DelayedPaymentMail.paid_intent_created(order_placement, data)
  end

  private

  def create_sample_order_placement
    employer = create_sample_employer
    job_offer = create_sample_job_offer(employer)

    OrderPlacement.new(
      id: "01234567890123456789012345",
      orderable: job_offer,
      price: 29900, # $299.00 in cents
      paid_on: Time.current,
      free_order: false,
      voucher_code: "STANDARD",
      created_at: Time.current,
      updated_at: Time.current
    )
  end

  def create_sample_order_placement_unpaid
    employer = create_sample_employer
    job_offer = create_sample_job_offer(employer)

    OrderPlacement.new(
      id: "01234567890123456789012345",
      orderable: job_offer,
      price: 29900, # $299.00 in cents
      paid_on: nil,
      free_order: false,
      voucher_code: "STANDARD",
      created_at: Time.current,
      updated_at: Time.current
    )
  end

  def create_sample_employer
    Employer.new(
      id: "01234567890123456789012345",
      email: "hiring@miningcompany.com",
      company_name: "Global Mining Solutions",
      created_at: Time.current,
      updated_at: Time.current
    )
  end

  def create_sample_job_offer(employer)
    JobOffer.new(
      id: "01234567890123456789012345",
      title: "Senior Mining Engineer",
      company_name: "Global Mining Solutions",
      employer: employer,
      category: "Engineering",
      region: "Australia",
      subregion: "Western Australia",
      approved: true,
      created_at: Time.current,
      updated_at: Time.current,
      slug: "senior-mining-engineer-global-mining-solutions"
    )
  end

  def create_sample_stripe_data
    {
      "next_action" => {
        "display_bank_transfer_instructions" => {
          "hosted_instructions_url" => "https://payments.stripe.com/bank_transfers/instructions/test_YWNjdF8xUlFRZXRRNzZ0dWw3WEpJLF9URDJhSk4yRGhUMERjVERIcjNLbzhSSUI5YWVWMTBG0100sWL4b8qV"
        }
      }
    }
  end
end
