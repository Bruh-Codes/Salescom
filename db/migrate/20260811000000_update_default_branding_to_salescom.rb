class UpdateDefaultBrandingToSalescom < ActiveRecord::Migration[7.1]
  class InstallationConfig < ActiveRecord::Base
    self.table_name = 'installation_configs'

    serialize :serialized_value, coder: YAML, type: ActiveSupport::HashWithIndifferentAccess, default: {}.with_indifferent_access

    def value
      serialized_value[:value]
    end

    def value=(new_value)
      self.serialized_value = { value: new_value }.with_indifferent_access
    end
  end

  def up
    InstallationConfig.where(name: %w[INSTALLATION_NAME BRAND_NAME]).find_each do |config|
      config.update!(value: 'Salescom') if config.value == 'Chatwoot'
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
