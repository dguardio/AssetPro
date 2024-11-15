class AddAssignedByToAssetAssignments < ActiveRecord::Migration[7.0]
  def change
    add_reference :asset_assignments, :assigned_by, null: false, foreign_key: { to_table: :users }
  end
end