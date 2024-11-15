class CreateMaintenanceSchedules < ActiveRecord::Migration[7.0]
  def change
    create_table :maintenance_schedules do |t|
      t.string :title
      t.text :description
      t.references :asset, null: false, foreign_key: true
      t.references :assigned_to, foreign_key: { to_table: :users }
      t.datetime :scheduled_date
      t.datetime :completed_date
      t.integer :status, default: 0
      t.text :notes

      t.timestamps
    end
  end
end