class AssetPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      case user
      when Doorkeeper::Application
        scope.with_deleted
      when User
        if user.admin? || user.manager?
          user.admin? ? scope.with_deleted : scope
        elsif user.security?
          scope.where(location_id: user.location_id)
        else
          scope.joins(:asset_assignments).where(asset_assignments: { user_id: user.id })
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
      true
    when User
      user.admin? || user.manager? || 
      (user.security? && record.location_id == user.location_id) ||
      record.users.include?(user)
    else
      false
    end
  end

  def create?
    # If the Doorkeeper::Application is an RFID reader, it can't create assets
    # RFID readers can only scan assets, but if the application is a mobile app, or erp
    # it can create assets
    return false if user.is_a?(Doorkeeper::Application)
    user.admin? || user.manager?
  end

  def update?
    return false if user.is_a?(Doorkeeper::Application)
    user.admin? || user.manager?
  end

  def export?
    return false if user.is_a?(Doorkeeper::Application)
    user.admin? || user.manager?
  end

  def import?
    return false if user.is_a?(Doorkeeper::Application)
    user.admin? || user.manager?
  end

  def destroy?
    return false if user.is_a?(Doorkeeper::Application)
    user.admin?
  end

  def restore?
    case user
    when User
      user.admin? || user.manager?
    else
      false
    end
  end
end 