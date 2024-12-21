class AddDeletedAtToMaintenanceRecords < ActiveRecord::Migration[7.0]
  def change
    add_column :maintenance_records, :deleted_at, :datetime
    add_index :maintenance_records, :deleted_at
  end
end
