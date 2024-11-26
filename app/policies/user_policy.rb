class UserPolicy < ApplicationPolicy
  def edit?
    # Users can only edit their own profile
    user == record
  end

  def update?
    edit?
  end

  def destroy?
    edit? || user.admin?
  end

  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.where(id: user.id)
      end
    end
  end
end 