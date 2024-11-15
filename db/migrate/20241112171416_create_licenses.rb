class CreateLicenses < ActiveRecord::Migration[7.0]
  def change
    create_table :licenses do |t|
      t.string :name
      t.text :description
      t.string :license_key
      t.integer :seats
      t.integer :seats_used, default: 0
      t.references :asset, foreign_key: true
      t.references :assigned_to, foreign_key: { to_table: :users }
      t.date :purchase_date
      t.date :expiration_date
      t.decimal :cost, precision: 10, scale: 2
      t.string :supplier
      t.text :notes

      t.timestamps
    end
  end
end