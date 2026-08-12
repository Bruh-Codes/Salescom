class DodoWebhookEvent < ApplicationRecord
  validates :webhook_id, presence: true
end
