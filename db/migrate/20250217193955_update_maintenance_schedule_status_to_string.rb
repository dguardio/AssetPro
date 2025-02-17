class UpdateMaintenanceScheduleStatusToString < ActiveRecord::Migration[7.0]
  def up
    # First, add a temporary column
    add_column :maintenance_schedules, :status_str, :string

    # Migrate the data
    MaintenanceSchedule.find_each do |schedule|
      # Map the old integer status to the new string status
      new_status = case schedule.read_attribute_before_type_cast('status')
                  when 0 then 'pending'
                  when 1 then 'in_progress'
                  when 2 then 'completed'
                  when 3 then 'overdue'
                  when 4 then 'cancelled'
                  else 'pending' # default value
                  end
      schedule.update_column(:status_str, new_status)
    end

    # Remove the old status column and rename the new one
    remove_column :maintenance_schedules, :status
    rename_column :maintenance_schedules, :status_str, :status

    # Add a not-null constraint and default value
    change_column_null :maintenance_schedules, :status, false, 'pending'
    change_column_default :maintenance_schedules, :status, 'pending'
  end

  def down
    # Add a temporary integer column
    add_column :maintenance_schedules, :status_int, :integer

    # Migrate the data back
    MaintenanceSchedule.find_each do |schedule|
      old_status = case schedule.status
                  when 'pending' then 0
                  when 'in_progress' then 1
                  when 'completed' then 2
                  when 'overdue' then 3
                  when 'cancelled' then 4
                  else 0 # default value
                  end
      schedule.update_column(:status_int, old_status)
    end

    # Remove the string status column and rename the integer one
    remove_column :maintenance_schedules, :status
    rename_column :maintenance_schedules, :status_int, :status

    # Add a not-null constraint and default value
    change_column_null :maintenance_schedules, :status, false, 0
    change_column_default :maintenance_schedules, :status, 0
  end
end