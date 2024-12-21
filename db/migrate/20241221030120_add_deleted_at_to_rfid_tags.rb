class AddDeletedAtToRfidTags < ActiveRecord::Migration[7.0]
  def change
    add_column :rfid_tags, :deleted_at, :datetime
    add_index :rfid_tags, :deleted_at
  end
end
