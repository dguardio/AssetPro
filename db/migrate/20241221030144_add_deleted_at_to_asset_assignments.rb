class AddDeletedAtToAssetAssignments < ActiveRecord::Migration[7.0]
  def change
    add_column :asset_assignments, :deleted_at, :datetime
    add_index :asset_assignments, :deleted_at
  end
end
