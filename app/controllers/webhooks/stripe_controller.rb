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
      rescue JSON::ParserError
        head :bad_request and return
      rescue ::Stripe::SignatureVerificationError
        head :bad_request and return
      end

      case event.type
      when "checkout.session.completed"
        session = event.data.object
        handle_checkout_session_completed(session)
      else
        raise "Unhandled event type: #{event.type}"
      end

      head :ok
    end

    private

    def handle_checkout_session_completed(session)
      order = OrderPlacement.find_by(stripe_session_id: session.id)
      raise "No order for #{session.id}" unless order
      order.update!(paid_at: Time.current)
      # Optionally, send confirmation email or trigger any post-payment logic
    end
  end
end
