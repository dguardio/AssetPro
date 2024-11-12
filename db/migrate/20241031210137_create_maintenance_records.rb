class CreateMaintenanceRecords < ActiveRecord::Migration[7.0]
  def change
    create_table :maintenance_records do |t|
      t.references :asset, null: false, foreign_key: true
      t.string :maintenance_type
      t.text :description
      t.date :scheduled_date
      t.date :completed_date
      t.decimal :cost
      t.string :performed_by

      t.timestamps
    end
  end
end
