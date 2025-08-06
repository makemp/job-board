module Webhooks
  class StripeController < ApplicationController
    skip_before_action :verify_authenticity_token
    skip_before_action :check_staging_access

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
      event_object = event.data.object
      client_reference_id = client_reference_id_resolver(event_object)

      order_placement = client_reference_id ? OrderPlacement.find_by(id: client_reference_id) : nil

      skip_order_placement = false

      case event_type
      when "checkout.session.completed"
        handle_checkout_session_completed(event_object, order_placement)
      when "customer.created",
           "customer.tax_id.created",
           "customer.tax_id.updated",
           "customer.updated"
        skip_order_placement = true
        StripeCustomerDataJob.set(wait: 1.minute).perform_later(event_type, event_object.to_hash)
      when "invoice_payment.paid"
        skip_order_placement = true
        logger.info "Stripe webhook received invoice_payment.paid. Data: #{event_object.to_hash}"
      end
      order_placement.update!(stripe_payload: order_placement.stripe_payload.merge({event_type => event_object.to_hash})) unless skip_order_placement
      head :ok
    rescue => e
      logger.error "Stripe webhook processing failed, error: #{e.message}, event_type: #{event_type}, payload: #{event_object.to_hash}"
      head :ok
    end

    private

    def client_reference_id_resolver(event_object)
      result = event_object.try(:client_reference_id)
      return result if result

      metadata = event_object.try(:metadata)
      return unless metadata
      metadata.to_hash.dig(:order_placement_id)
    end

    def handle_checkout_session_completed(session, order_placement)
      raise "No order for #{session.id}" unless order_placement
      employer = order_placement.employer
      order_placement.update!(paid_on: Time.current)

      hsh = {}
      hsh[:stripe_customer_id] = session.customer if employer.stripe_customer_id.blank?
      if employer.confirmed_at.blank?
        hsh[:confirmed_at] = Time.current
        hsh[:confirmation_token] = nil
      end

      employer.update!(hsh) if hsh.present?
    end
  end
end
