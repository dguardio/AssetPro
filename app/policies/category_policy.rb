class CategoryPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all # Categories are typically visible to all authenticated users
    end
  end

  def show?
    true # Categories are viewable by all authenticated users
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