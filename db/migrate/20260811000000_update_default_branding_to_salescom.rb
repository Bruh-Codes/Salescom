class UpdateDefaultBrandingToSalescom < ActiveRecord::Migration[7.1]
  def up
    installation_configs = Class.new(ActiveRecord::Base) do
      self.table_name = 'installation_configs'
    end

    installation_configs.where(name: %w[INSTALLATION_NAME BRAND_NAME], value: 'Chatwoot').update_all(value: 'Salescom')
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
