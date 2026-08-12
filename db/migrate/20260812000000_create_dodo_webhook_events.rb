class CreateDodoWebhookEvents < ActiveRecord::Migration[7.1]
  def change
    create_table :dodo_webhook_events do |t|
      t.string :webhook_id, null: false
      t.string :event_type, null: false
      t.timestamps
    end

    add_index :dodo_webhook_events, :webhook_id, unique: true
  end
end
