class CreateRfidReaders < ActiveRecord::Migration[7.0]
  def change
    create_table :rfid_readers do |t|
      t.string :reader_id, null: false
      t.string :name
      t.string :position # e.g., 'exit', 'entrance', 'gate-1'
      t.boolean :active, default: true
      t.datetime :last_ping_at
      t.timestamps
    end
    add_index :rfid_readers, :reader_id, unique: true
  end
end
