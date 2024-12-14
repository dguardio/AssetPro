class AddOauthApplicationIdToRfidReaders < ActiveRecord::Migration[7.0]
  def change
    add_reference :rfid_readers, :oauth_application, null: false, foreign_key: true
  end
end
