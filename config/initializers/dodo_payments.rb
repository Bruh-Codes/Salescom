require 'dodopayments'

DODO_PAYMENTS = Dodopayments::Client.new(
  bearer_token: ENV.fetch('DODO_PAYMENTS_API_KEY', nil),
  webhook_key: ENV.fetch('DODO_PAYMENTS_WEBHOOK_KEY', nil),
  environment: ENV.fetch('DODO_PAYMENTS_ENVIRONMENT', 'test_mode')
)
