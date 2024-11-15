class AuditLog < ApplicationRecord
  belongs_to :auditable, polymorphic: true
  belongs_to :user

  # Rename the column from 'changes' to 'audit_changes'
end 