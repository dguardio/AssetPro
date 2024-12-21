class AddDeletedAtToAssets < ActiveRecord::Migration[7.0]
  def change
    add_column :assets, :deleted_at, :datetime
    add_index :assets, :deleted_at
  end
end
