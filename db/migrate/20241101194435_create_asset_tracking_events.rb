class CreateAssetTrackingEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :asset_tracking_events do |t|
      t.references :asset, null: false, foreign_key: true
      t.references :location, null: false, foreign_key: true
      t.references :scanned_by, null: false, foreign_key: { to_table: :users }
      t.string :event_type
      t.string :rfid_number
      t.datetime :scanned_at

      t.timestamps
    end
    add_index :asset_tracking_events, :rfid_number
  end
end
