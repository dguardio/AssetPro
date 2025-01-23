class AssetRequestPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin? || user.manager?
        scope.all
      else
        scope.where(user: user)
      end
    end
  end

  def index?
    true
  end

  def show?
    user.admin? || user.manager? || record.user == user
  end

  def create?
    true
  end

  def update?
    user.admin? || record.user == user
  end

  def destroy?
    user.admin? || record.user == user
  end

  def approve?
    user.admin? || user.manager?
  end

  def reject?
    user.admin? || user.manager?
  end
end 