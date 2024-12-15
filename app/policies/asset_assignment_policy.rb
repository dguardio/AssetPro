
class AssetAssignmentPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      case user
      when Doorkeeper::Application
        # OAuth applications can see assignments for all assets.
        scope.all
      when User
        case user.role
        when 'admin', 'manager'
          scope.all
        when 'security'
          scope.joins(:asset).where(assets: { location_id: user.location_id })
        else
          scope.where(user: user)
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
    user.admin?
  end
end 