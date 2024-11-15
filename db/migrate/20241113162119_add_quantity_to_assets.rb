class AddQuantityToAssets < ActiveRecord::Migration[7.0]
  def change
    add_column :assets, :quantity, :integer, default: 1, null: false
    add_column :assets, :minimum_quantity, :integer, default: 1, null: false
  end
end