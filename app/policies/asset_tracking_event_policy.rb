class AssetTrackingEventPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      case user.role
      when 'admin'
        scope.all
      when 'manager'
        scope.all
      when 'security'
        scope.all
      when 'user'
        scope.where(scanned_by: user)
      else
        scope.none
      end
    end
  end

  def index?
    user.admin? || user.manager? || user.security?
  end

  def show?
    user.admin? || user.manager? || user.security? || record.scanned_by_id == user.id
  end

  def create?
    user.admin? || user.manager? || user.security?
  end

  def update?
    user.admin?
  end

  def timeline?
    user.admin? || user.manager? || user.security?
  end

  def destroy?
    user.admin?
  end
end 