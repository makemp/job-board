require "stripe"

Stripe.api_key = ENV["STRIPE_BASE_SECRET_KEY"] || Rails.application.credentials.dig(:stripe, :secret_key)
Rails.configuration.stripe = {
  publishable_key: ENV["STRIPE_BASE_PUBLISHABLE_KEY"] || Rails.application.credentials.dig(:stripe, :publishable_key),
  webhook_secret: ENV["STRIPE_BASE_WEBHOOK_SECRET"] || Rails.application.credentials.dig(:stripe, :webhook_secret),
  currency: Rails.application.credentials.dig(:stripe, :currency) || "gbp"
}
