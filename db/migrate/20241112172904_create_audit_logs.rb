class CreateAuditLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :audit_logs do |t|
      t.references :auditable, polymorphic: true
      t.references :user, foreign_key: true
      t.string :action
      t.json :changes
      
      t.timestamps
    end
  end
end