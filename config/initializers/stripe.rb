Rails.configuration.stripe = Rails.application.config.stripe
Stripe.api_key = Rails.configuration.stripe[:secret_key]
