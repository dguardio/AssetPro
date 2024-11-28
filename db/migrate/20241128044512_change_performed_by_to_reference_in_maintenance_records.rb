class ChangePerformedByToReferenceInMaintenanceRecords < ActiveRecord::Migration[7.0]
  def change
    # Remove the old string column
    remove_column :maintenance_records, :performed_by, :string
    
    # Add the new reference column
    add_reference :maintenance_records, :performed_by, foreign_key: { to_table: :users }
  end
end
