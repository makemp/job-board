module Stripe
  class CheckoutSessionService
    @host = Rails.application.config.action_controller.default_url_options[:host]
    @url_helpers = Rails.application.routes.url_helpers

    def self.call(order_placement:)
      session = ::Stripe::Checkout::Session.create(
        payment_method_types: ["card"],
        line_items: [{
          price_data: {
            currency: Rails.configuration.stripe[:currency],
            unit_amount: order_placement.price,
            product_data: {
              name: order_placement.job_offer.title
            }
          },
          quantity: 1
        }],
        mode: "payment",
        success_url: @url_helpers.order_placement_url(order_placement, host: @host) + "?success=true",
        cancel_url: @url_helpers.job_offer_url(order_placement.job_offer, host: @host)
      )
      order_placement.update!(stripe_session_id: session.id)
      session
    end
  end
end
