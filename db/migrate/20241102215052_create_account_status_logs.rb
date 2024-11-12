class CreateAccountStatusLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :account_status_logs do |t|
      t.references :user, null: false, foreign_key: true
      t.references :changed_by, null: false, foreign_key: { to_table: :users }
      t.boolean :status_from
      t.boolean :status_to
      t.text :reason

      t.timestamps
    end
  end
end
