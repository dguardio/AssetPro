class RfidTagPolicy < ApplicationPolicy
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
          scope.joins(:asset).where(assets: { location_id: user.location_id })
        else
          scope.joins(asset: :asset_assignments)
               .where(asset_assignments: { user_id: user.id })
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
      (user.security? && record.asset&.location_id == user.location_id)
    else
      false
    end
  end

  def create?
    case user
    when Doorkeeper::Application
      true
    when User
      user.admin?
    else
      false
    end
  end

  def update?
    case user
    when Doorkeeper::Application
      true
    when User
      user.admin?
    else
      false
    end
  end

  def destroy?
    case user
    when Doorkeeper::Application
      true
    when User
      user.admin?
    else
      false
    end
  end
end 