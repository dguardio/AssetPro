class AddDepreciationRateToAssets < ActiveRecord::Migration[7.0]
  def change
    add_column :assets, :depreciation_rate, :decimal, precision: 5, scale: 2
  end
end