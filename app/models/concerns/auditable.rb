module Auditable
  extend ActiveSupport::Concern

  included do
    after_create :log_create
    after_update :log_update
    after_destroy :log_destroy
  end

  private

  def log_create
    return if $skip_auditing
    return unless RequestStore.store[:current_user]

    AuditLog.create!(
      user: RequestStore.store[:current_user],
      action: 'create',
      auditable: self,
      audit_changes: {
        'created' => {
          'before' => {},
          'after' => self.attributes
        }
      }.to_json
    )
  end

  def log_update
    return if $skip_auditing
    return unless RequestStore.store[:current_user]

    AuditLog.create!(
      user: RequestStore.store[:current_user],
      action: 'update',
      auditable: self,
      audit_changes: {
        'updated' => {
          'before' => self.saved_changes.transform_values(&:first),
          'after' => self.saved_changes.transform_values(&:last)
        }
      }.to_json
    )
  end

  def log_destroy
    return if $skip_auditing
    return unless RequestStore.store[:current_user]

    AuditLog.create!(
      user: RequestStore.store[:current_user],
      action: 'delete',
      auditable: self,
      audit_changes: {
        'deleted' => {
          'before' => self.attributes,
          'after' => {}
        }
      }.to_json
    )
  end
end 