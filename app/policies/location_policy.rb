class LocationPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      case user
      when Doorkeeper::Application
        scope.all
      when User
        case user.role
        when 'admin', 'manager'
          scope.all
        when 'security'
          scope.where(id: user.location_id)
        else
          scope.joins(assets: :asset_assignments)
               .where(asset_assignments: { user_id: user.id })
               .distinct
        end
      else
        scope.none
      end
    end
  end

  def show?
    case user
    when Doorkeeper::Application
      true
    when User
      user.admin? || user.manager? || 
      user.location_id == record.id ||
      user.locations.include?(record)
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
end 