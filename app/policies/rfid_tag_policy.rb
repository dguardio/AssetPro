class RfidTagPolicy < ApplicationPolicy
  def create?
    user.admin? || user.manager?
  end

  def destroy?
    user.admin? || user.manager?
  end
end 