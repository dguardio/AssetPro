class LocationPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.joins(assets: :asset_assignments)
             .where(asset_assignments: { user_id: user.id })
             .distinct
      end
    end
  end

  def show?
    user.admin? || user.locations.include?(record)
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