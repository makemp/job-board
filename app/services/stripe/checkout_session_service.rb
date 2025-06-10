module Stripe
  class CheckoutSessionService
    HOST = Rails.application.config.action_controller.default_url_options[:host]
    PORT = Rails.application.config.action_controller.default_url_options[:port]
    URL_HELPERS = Rails.application.routes.url_helpers

    def self.call(order_placement:)
      new(order_placement:).call
    end

    def initialize(order_placement:)
      @order_placement = order_placement
    end

    def call
      session = ::Stripe::Checkout::Session.create(
        payment_method_types: %w[card revolut_pay pay_by_bank],
        line_items: [{
          price_data: {
            currency: Rails.configuration.stripe[:currency],
            unit_amount: order_placement.price * 100, # Convert to cents
            product_data: {
              name: "Job Offer Placement"
            }
          },
          quantity: 1
        }],
        billing_address_collection: "required",
        tax_id_collection: {
          enabled: true
        },
        mode: "payment",
        success_url: URL_HELPERS.order_placement_url(order_placement, host: host) + "?success=true",
        cancel_url: URL_HELPERS.new_job_offer_forms_url(host: host, job_offer_form: order_placement.job_offer_params["attributes"]) + "?cancel=true"
      )
      order_placement.update!(stripe_session_id: session.id)
      session
    end

    private

    def host
      (HOST[/\d*/] || HOST[/localhost/]) ? "#{HOST}:#{PORT}" : HOST
    end

    attr_reader :order_placement
  end
end
