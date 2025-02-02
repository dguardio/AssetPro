class AssetAssignmentPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      case user
      when Doorkeeper::Application
        scope.with_deleted
      when User
        base_scope = user.admin? ? scope.with_deleted : scope
        case user.role
        when 'admin', 'manager'
          base_scope
        when 'security'
          base_scope.joins(:asset).where(assets: { location_id: user.location_id })
        else
          base_scope.where(user: user)
        end
      else
        scope.none
      end
    end
  end

  def index?
    case user
    when Doorkeeper::Application
      true
    when User
      user.admin? || user.manager? || user.security?
    else
      false
    end
  end

  def show?
    case user
    when Doorkeeper::Application
      record.asset.location_id == user.location_id
    when User
      user.admin? || user.manager? || 
      (user.security? && record.asset.location_id == user.location_id) ||
      record.user_id == user.id
    else
      false
    end
  end

  def create?
    return false if user.is_a?(Doorkeeper::Application)
    user.admin? || user.manager?
  end

  def update?
    return false if user.is_a?(Doorkeeper::Application)
    user.admin? || user.manager?
  end

  def destroy?
    return false if user.is_a?(Doorkeeper::Application)
    user.admin? || user.manager?
  end

  def restore?
    return false if user.is_a?(Doorkeeper::Application)
    user.admin?
  end

  def check_in?
    case user
    when Doorkeeper::Application
      true  # Allow mobile app to check in
    when User
      user.admin? || user.manager?
    else
      false
    end
  end

  def check_out?
    case user
    when Doorkeeper::Application
      true  # Allow mobile app to check out
    when User
      user.admin? || user.manager?
    else
      false
    end
  end
end 