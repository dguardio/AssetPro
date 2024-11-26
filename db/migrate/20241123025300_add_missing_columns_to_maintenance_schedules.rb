class AddMissingColumnsToMaintenanceSchedules < ActiveRecord::Migration[7.0]
  def change
    add_column :maintenance_schedules, :frequency, :string
    add_column :maintenance_schedules, :next_due_at, :datetime
    add_column :maintenance_schedules, :last_performed_at, :datetime
    
    # Remove columns that aren't used in the new model
    remove_column :maintenance_schedules, :scheduled_date, :datetime
    
    # Add indexes for frequently queried columns
    add_index :maintenance_schedules, :next_due_at
    add_index :maintenance_schedules, :status
    add_index :maintenance_schedules, [:asset_id, :next_due_at]
  end
end