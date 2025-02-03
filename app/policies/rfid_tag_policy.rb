class RfidTagPolicy < ApplicationPolicy
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
          base_scope.joins(asset: :asset_assignments)
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
    if user.is_a?(Doorkeeper::Application)
      true
    elsif user.admin?
      true
    else
      false
    end
  end

  def restore?
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