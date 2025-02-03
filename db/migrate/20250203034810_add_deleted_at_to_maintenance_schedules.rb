class AddDeletedAtToMaintenanceSchedules < ActiveRecord::Migration[7.0]
  def change
    add_column :maintenance_schedules, :deleted_at, :datetime
    add_index :maintenance_schedules, :deleted_at
  end
end
