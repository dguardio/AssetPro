class MaintenanceRecordPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.joins(asset: :asset_assignments)
             .where(asset_assignments: { user_id: user.id })
             .distinct
      end
    end
  end

  def index?
    true
  end

  def show?
    user.admin? || record.performed_by_id == user.id || record.asset&.location_id == user.location_id
  end

  def create?
    user.admin? || record.asset.users.include?(user)
  end

  def update?
    user.admin? || (record.performed_by_user == user)
  end

  def destroy?
    user.admin?
  end
end 