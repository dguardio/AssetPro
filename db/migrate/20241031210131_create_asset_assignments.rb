class CreateAssetAssignments < ActiveRecord::Migration[7.0]
  def change
    create_table :asset_assignments do |t|
      t.references :asset, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.datetime :checked_out_at
      t.datetime :checked_in_at
      t.text :notes

      t.timestamps
    end
  end
end
