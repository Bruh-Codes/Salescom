class Billing::DodoPaymentsService
  def initialize(account:)
    @account = account
  end

  def checkout_url
    session = DODO_PAYMENTS.checkout_sessions.create(
      product_cart: [{ product_id: ENV.fetch('DODO_PAYMENTS_PRODUCT_ID'), quantity: 1 }],
      customer: { email: billing_user.email, name: billing_user.name },
      metadata: { account_id: @account.id },
      return_url: billing_url
    )
    session.checkout_url
  end

  def portal_url
    customer_id = @account.custom_attributes.fetch('dodo_customer_id')
    DODO_PAYMENTS.customers.customer_portal.create(customer_id, return_url: billing_url).link
  end

  private

  def billing_user
    @account.administrators.first!
  end

  def billing_url
    "#{ENV.fetch('FRONTEND_URL')}/app/accounts/#{@account.id}/settings/billing"
  end
end
