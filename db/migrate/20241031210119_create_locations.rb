class CreateLocations < ActiveRecord::Migration[7.0]
  def change
    create_table :locations do |t|
      t.string :name
      t.text :address
      t.string :building
      t.string :floor
      t.string :room

      t.timestamps
    end
  end
end
