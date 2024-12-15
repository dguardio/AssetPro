class RfidReaderPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      case user
      when Doorkeeper::Application
        scope.where(oauth_application: user)
      when User
        case user.role
        when 'admin'
          scope.all
        when 'manager', 'security'
          scope.joins(:location).where(locations: { id: user.location_id })
        else
          scope.none
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
      user.admin? || 
      (user.manager? && record.location_id == user.location_id) ||
      (user.security? && record.location_id == user.location_id)
    else
      false
    end
  end

  def create?
    return false if user.is_a?(Doorkeeper::Application)
    user.admin?
  end

  def update?
    return false if user.is_a?(Doorkeeper::Application)
    user.admin?
  end

  def destroy?
    return false if user.is_a?(Doorkeeper::Application)
    user.admin?
  end

  def toggle_active?
    return false if user.is_a?(Doorkeeper::Application)
    user.admin? || 
    (user.manager? && record.location_id == user.location_id)
  end
end 