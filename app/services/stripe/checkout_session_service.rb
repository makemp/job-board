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
      order_placement.update!(session_token: SecureRandom.hex(10))
      session = ::Stripe::Checkout::Session.create(checkout_params.merge(customer_params))

      order_placement.update!(stripe_session_id: session.id)
      session
    end

    private

    def checkout_params
      {
        payment_method_types: %w[card],
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
        invoice_creation: {
          enabled: true,
          invoice_data: {
            # This metadata will be on the Invoice object itself
            metadata: {
              order_placement_id: order_placement.id.to_s
            },
            # This will be visible on the PDF for the customer
            custom_fields: [
              {name: "Order ID", value: order_placement.id.to_s}
            ]
          }
        },
        payment_intent_data: {
          metadata: {
            order_placement_id: order_placement.id.to_s
          }
        },
        client_reference_id: order_placement.id.to_s,

        success_url: URL_HELPERS.completed_order_url(order_placement, session_token: order_placement.session_token, host: host),
        cancel_url: URL_HELPERS.new_job_offer_forms_url(host: host, order_placement_id: order_placement.id, cancelled: true)
      }
    end

    def customer_params
      stripe_customer_id = order_placement.employer.stripe_customer_id
      return {customer: stripe_customer_id, customer_update: {name: "auto", address: "auto"}} if stripe_customer_id
      {customer_email: order_placement.email, customer_creation: "always"}
    end

    def host
      (HOST[/\d*/] || HOST[/localhost/]) ? "#{HOST}:#{PORT}" : HOST
    end

    attr_reader :order_placement
  end
end
