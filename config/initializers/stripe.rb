require "stripe"

Stripe.api_key = Rails.application.credentials.dig(:stripe, :secret_key)
Rails.configuration.stripe = {
  publishable_key: Rails.application.credentials.dig(:stripe, :publishable_key),
  webhook_secret: Rails.application.credentials.dig(:stripe, :webhook_secret),
  currency: Rails.application.credentials.dig(:stripe, :currency) || "gbp"
}
