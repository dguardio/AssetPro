class AuditLogPolicy < ApplicationPolicy
  
  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        # For non-admins, show logs related to their actions or resources they own
        scope.where(user_id: user.id)
      end
    end
  end

  def index?
    true # Everyone can view logs, but they'll be filtered by the scope
  end

  def show?
    user.admin? || record.user_id == user.id
  end

  def for_record?
    user.present?
  end
end 
