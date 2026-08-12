class Api::V1::Accounts::BillingsController < Api::V1::Accounts::BaseController
  before_action :authorize_billing

  def show
    render json: Current.account.custom_attributes.slice(
      'plan_name', 'dodo_customer_id', 'dodo_subscription_id', 'subscription_ends_on'
    )
  end

  def checkout
    render json: { redirect_url: billing_service.checkout_url }
  end

  def portal
    render json: { redirect_url: billing_service.portal_url }
  end

  private

  def authorize_billing
    authorize Current.account, :subscription?
  end

  def billing_service
    @billing_service ||= Billing::DodoPaymentsService.new(account: Current.account)
  end
end
