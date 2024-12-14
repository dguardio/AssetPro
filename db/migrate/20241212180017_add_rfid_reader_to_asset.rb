class AddRfidReaderToAsset < ActiveRecord::Migration[7.0]
  def change
    add_reference :asset_tracking_events, :rfid_reader, foreign_key: true
  end
end
