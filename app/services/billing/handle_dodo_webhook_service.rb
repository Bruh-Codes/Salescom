class Billing::HandleDodoWebhookService
  class InvalidSignature < StandardError; end

  ACTIVE_EVENTS = %w[
    subscription.active
    subscription.renewed
    subscription.updated
    subscription.plan_changed
  ].freeze
  ON_HOLD_EVENTS = %w[subscription.on_hold].freeze
  INACTIVE_EVENTS = %w[
    subscription.cancelled
    subscription.expired
    subscription.failed
  ].freeze
  TRACKED_EVENTS = (ACTIVE_EVENTS + ON_HOLD_EVENTS + INACTIVE_EVENTS).freeze

  def initialize(payload:, headers:)
    @event = DODO_PAYMENTS.webhooks.unwrap(payload, headers: headers)
    @event_type = value(@event, :type).to_s
    @webhook_id = headers['webhook-id'] || headers['webhook_id']
    raise InvalidSignature, 'Missing webhook id' if @webhook_id.blank?
  rescue StandardError => e
    raise InvalidSignature, e.message
  end

  def perform
    return unless TRACKED_EVENTS.include?(@event_type)

    DodoWebhookEvent.transaction(requires_new: true) do
      DodoWebhookEvent.create!(webhook_id: @webhook_id, event_type: @event_type)
      synchronize_subscription
    end
  rescue ActiveRecord::RecordNotUnique
    nil
  end

  private

  def synchronize_subscription
    subscription = value(@event, :data)
    customer = value(subscription, :customer)
    account_id = metadata_value(value(subscription, :metadata), :account_id)
    account_id ||= metadata_value(value(customer, :metadata), :account_id)
    raise ActiveRecord::RecordNotFound, 'Dodo webhook account metadata is missing' if account_id.blank?

    account = Account.find(account_id)
    attributes = account.custom_attributes || {}
    attributes = attributes.merge('subscription_status' => subscription_status)

    customer_id = value(customer, :customer_id)
    subscription_id = value(subscription, :subscription_id)
    next_billing_date = value(subscription, :next_billing_date) ||
                        value(subscription, :expires_at) ||
                        value(subscription, :cancelled_at)
    product_id = value(subscription, :product_id)

    attributes['dodo_customer_id'] = customer_id if customer_id.present?
    attributes['dodo_subscription_id'] = subscription_id if subscription_id.present?
    attributes['subscription_ends_on'] = next_billing_date if next_billing_date.present?

    if (ACTIVE_EVENTS + ON_HOLD_EVENTS).include?(@event_type)
      attributes['plan_name'] = product_id if product_id.present?
    elsif INACTIVE_EVENTS.include?(@event_type)
      attributes['plan_name'] = nil
    end

    account.update!(custom_attributes: attributes)
  end

  def subscription_status
    return 'active' if ACTIVE_EVENTS.include?(@event_type)
    return 'on_hold' if ON_HOLD_EVENTS.include?(@event_type)

    @event_type.delete_prefix('subscription.')
  end

  def metadata_value(metadata, key)
    return if metadata.blank?

    value(metadata, key) || value(metadata, key.to_s)
  end

  def value(object, key)
    return if object.nil?
    return object.public_send(key) if object.respond_to?(key)
    return object[key] if object.respond_to?(:[]) && object[key].present?

    string_key = key.to_s
    object[string_key] if object.respond_to?(:[])
  end
end
