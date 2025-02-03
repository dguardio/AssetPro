class AddMaintenanceScheduleToMaintenanceRecords < ActiveRecord::Migration[7.0]
  def change
    add_reference :maintenance_records, :maintenance_schedule, foreign_key: true
  end
end