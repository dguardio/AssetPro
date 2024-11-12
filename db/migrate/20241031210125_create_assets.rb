class CreateAssets < ActiveRecord::Migration[7.0]
  def change
    create_table :assets do |t|
      t.string :name
      t.text :description
      t.string :asset_code
      t.string :status
      t.date :purchase_date
      t.decimal :purchase_price
      t.references :category, null: false, foreign_key: true
      t.references :location, null: false, foreign_key: true

      t.timestamps
    end
    add_index :assets, :asset_code, unique: true
  end
end
