class LicensePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      case user
      when Doorkeeper::Application
        scope.none # OAuth apps don't need license access
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
    return false if user.is_a?(Doorkeeper::Application)
    user.admin? || user.manager? || user.security?
  end

  def show?
    return false if user.is_a?(Doorkeeper::Application)
    user.admin? || user.manager? ||
    (user.security? && record.asset&.location_id == user.location_id)
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