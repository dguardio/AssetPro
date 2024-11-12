class AssetAssignmentPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.where(user_id: user.id)
      end
    end
  end

  def show?
    user.admin? || record.user_id == user.id
  end

  def create?
    user.admin?
  end

  def destroy?
    user.admin?
  end
end 