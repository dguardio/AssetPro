class AddFinancialFieldsToAssets < ActiveRecord::Migration[7.0]
  def change
    add_column :assets, :useful_life_years, :integer, optional: true
    add_column :assets, :salvage_value, :decimal, precision: 10, scale: 2, optional: true
    add_column :assets, :warranty_expiry_date, :date, optional: true
    add_column :assets, :maintenance_cost_yearly, :decimal, precision: 10, scale: 2, optional: true
    add_column :assets, :insurance_value, :decimal, precision: 10, scale: 2, optional: true
    
    # Make purchase fields required and add precision
    change_column :assets, :purchase_price, :decimal, precision: 10, scale: 2, optional: true
  end
end
