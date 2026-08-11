class UpdateDefaultBrandingToSalescom < ActiveRecord::Migration[7.1]
  def up
    installation_configs = Class.new(ActiveRecord::Base) do
      self.table_name = 'installation_configs'
      serialize :serialized_value, coder: YAML, type: ActiveSupport::HashWithIndifferentAccess, default: {}.with_indifferent_access
    end

    installation_configs.where(name: %w[INSTALLATION_NAME BRAND_NAME]).find_each do |config|
      next unless config.serialized_value[:value] == 'Chatwoot'

      config.serialized_value = config.serialized_value.merge(value: 'Salescom').with_indifferent_access
      config.save!
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
