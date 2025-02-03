class CreateAssetLicenses < ActiveRecord::Migration[7.0]
  def change
    create_table :asset_licenses do |t|
      t.references :asset, null: false, foreign_key: true
      t.references :license, null: false, foreign_key: true
      t.datetime :assigned_at
      t.datetime :deleted_at, index: true

      t.timestamps
    end

    add_index :asset_licenses, [:asset_id, :license_id], unique: true
  end
end