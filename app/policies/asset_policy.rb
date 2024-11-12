class AssetPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.joins(:asset_assignments).where(asset_assignments: { user_id: user.id })
      end
    end
  end

  def show?
    user.admin? || record.users.include?(user)
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