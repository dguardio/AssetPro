class CreateAssetRequests < ActiveRecord::Migration[7.0]
  def change
    create_table :asset_requests do |t|
      t.references :user, null: false, foreign_key: true
      t.references :asset, null: false, foreign_key: true
      t.string :status, default: 'pending'
      t.text :purpose
      t.datetime :requested_from
      t.datetime :requested_until
      t.text :rejection_reason
      t.references :reviewed_by, foreign_key: { to_table: :users }
      t.datetime :reviewed_at

      t.timestamps
      t.datetime :deleted_at
    end
    add_index :asset_requests, :deleted_at
  end
end