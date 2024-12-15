class AssetTrackingEventPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      case user
      when Doorkeeper::Application
        # RFID readers can see their own events
        scope.where(oauth_application: user)
      when User
        case user.role
        when 'admin', 'manager'
          scope.all
        when 'security'
          scope.where(location_id: user.location_id)
        else
          scope.where(scanned_by: user)
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
      record.oauth_application_id == user.id
    when User
      user.admin? || user.manager? || user.security? || 
      record.scanned_by_id == user.id
    else
      false
    end
  end

  def create?
    case user
    when Doorkeeper::Application
      user.app_type == 'rfid_reader'
    when User
      user.admin? || user.manager? || user.security?
    else
      false
    end
  end

  def update?
    return false if user.is_a?(Doorkeeper::Application)
    user.admin?
  end

  def destroy?
    return false if user.is_a?(Doorkeeper::Application)
    user.admin?
  end
end 