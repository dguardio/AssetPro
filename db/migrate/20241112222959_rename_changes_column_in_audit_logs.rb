class RenameChangesColumnInAuditLogs < ActiveRecord::Migration[7.0]
  def change
    rename_column :audit_logs, :changes, :audit_changes
  end
end