class AllowNullAssetIdInRfidTags < ActiveRecord::Migration[7.0]
  def change
    change_column_null :rfid_tags, :asset_id, true
  end
end
