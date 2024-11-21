class AuditLogPolicy < ApplicationPolicy
  def index?
    user.present?  # or whatever authorization logic you need
  end

  def show?
    user.present?
  end

  def for_record?
    user.present?
  end
end 