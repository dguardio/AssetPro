class CreateRfidTags < ActiveRecord::Migration[7.0]
  def change
    create_table :rfid_tags do |t|
      t.string :rfid_number
      t.boolean :active
      t.references :asset, null: false, foreign_key: true
      t.datetime :last_scanned_at
      t.references :location, foreign_key: true

      t.timestamps
    end
    add_index :rfid_tags, :rfid_number
  end
end
