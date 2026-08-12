class Webhooks::DodoPaymentsController < ActionController::Base
  def create
    Billing::HandleDodoWebhookService.new(payload: request.raw_post, headers: webhook_headers).perform
    head :ok
  end

  private

  def webhook_headers
    request.headers.env.filter_map do |key, value|
      [key.delete_prefix('HTTP_').downcase.tr('_', '-'), value] if key.start_with?('HTTP_WEBHOOK_')
    end.to_h
  end
end
