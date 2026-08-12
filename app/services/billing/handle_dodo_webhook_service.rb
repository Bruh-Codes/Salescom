class Billing::HandleDodoWebhookService
  ACTIVE_EVENTS = %w[subscription.active subscription.renewed subscription.updated subscription.plan_changed].freeze
  INACTIVE_EVENTS = %w[subscription.cancelled subscription.expired subscription.failed].freeze

  def initialize(payload:, headers:)
    @event = DODO_PAYMENTS.webhooks.unwrap(payload, headers: headers)
  end

  def perform
    return unless ACTIVE_EVENTS.include?(@event.type.to_s) || INACTIVE_EVENTS.include?(@event.type.to_s)

    subscription = @event.data
    account = Account.find(subscription.metadata.fetch(:account_id))
    attributes = account.custom_attributes.merge(
      'dodo_customer_id' => subscription.customer.customer_id,
      'dodo_subscription_id' => subscription.subscription_id,
      'subscription_ends_on' => subscription.next_billing_date
    )
    attributes['plan_name'] = ACTIVE_EVENTS.include?(@event.type.to_s) ? subscription.product_id : nil
    account.update!(custom_attributes: attributes)
  end
end
