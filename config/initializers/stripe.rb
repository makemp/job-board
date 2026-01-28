require "stripe"

if ENV["STAGING_ENV"].present?
  stripe_base_secret_key = ENV["STRIPE_BASE_SECRET_KEY"]
  stripe_base_publishable_key = ENV["STRIPE_BASE_PUBLISHABLE_KEY"]
  stripe_base_webhook_secret = ENV["STRIPE_BASE_WEBHOOK_SECRET"]
elsif Rails.env.production?
  stripe_base_secret_key = ENV["PRODUCTION_STRIPE_BASE_SECRET_KEY"]
  stripe_base_publishable_key = ENV["PRODUCTION_STRIPE_BASE_PUBLISHABLE_KEY"]
  stripe_base_webhook_secret = ENV["PRODUCTION_STRIPE_BASE_WEBHOOK_SECRET"]
else
  stripe_base_secret_key = Rails.application.credentials.dig(:stripe, :secret_key)
  stripe_base_publishable_key = Rails.application.credentials.dig(:stripe, :publishable_key)
  stripe_base_webhook_secret = Rails.application.credentials.dig(:stripe, :webhook_secret)
end

Stripe.api_key = stripe_base_secret_key
Rails.configuration.stripe = {
  publishable_key: stripe_base_publishable_key,
  webhook_secret: stripe_base_webhook_secret,
  currency: Rails.application.credentials.dig(:stripe, :currency) || "gbp"
}
