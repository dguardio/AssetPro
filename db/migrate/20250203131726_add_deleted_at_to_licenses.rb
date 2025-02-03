class AddDeletedAtToLicenses < ActiveRecord::Migration[7.0]
  def change
    add_column :licenses, :deleted_at, :datetime
    add_index :licenses, :deleted_at
  end
end