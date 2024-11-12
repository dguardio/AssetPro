class AddRfidFieldsToAssets < ActiveRecord::Migration[7.0]
  def change
    add_column :assets, :rfid_enabled, :boolean
    add_column :assets, :last_tracked_at, :datetime
  end
end
