class MaintenanceSchedulePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.where(assigned_to: user)
          .or(scope.joins(:asset).where(assets: { location_id: user.location_id }))
      end
    end
  end

  def index?
    true
  end

  def show?
    user.admin? || record.assigned_to_id == user.id || record.asset&.location_id == user.location_id
  end

  def create?
    user.admin?
  end

  def update?
    user.admin?
  end

  def destroy?
    user.admin?
  end
end 
