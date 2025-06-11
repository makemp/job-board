module Webhooks
  class StripeController < ApplicationController
    skip_before_action :verify_authenticity_token

    def receive
      payload = request.body.read
      sig_header = request.env["HTTP_STRIPE_SIGNATURE"]
      begin
        event = ::Stripe::Webhook.construct_event(
          payload, sig_header, Rails.configuration.stripe[:webhook_secret]
        )
      rescue JSON::ParserError => e
        logger.error "Stripe webhook JSON parsing failed, error: #{e.message},  payload: #{payload}"
        head :bad_request and return
      rescue ::Stripe::SignatureVerificationError => e
        logger.error "Stripe signature verification failed, error: #{e.message},  payload: #{payload}"
        head :bad_request and return
      end

      event_type = event.type
      session = event.data&.object
      order_placement = OrderPlacement.find_by(stripe_session_id: session.id)
      payload = JSON.parse(payload)

      case event_type
      when "checkout.session.completed"
        handle_checkout_session_completed(session, order_placement)
      end
      order_placement&.update!(stripe_payload: order_placement.stripe_payload.merge({event_type => payload}))
      head :ok
    end

    private

    def handle_checkout_session_completed(session, order_placement)
      raise "No order for #{session.id}" unless order_placement
      order_placement.update!(paid_at: Time.current)
      # Optionally, send confirmation email or trigger any post-payment logic
    end
  end
end
