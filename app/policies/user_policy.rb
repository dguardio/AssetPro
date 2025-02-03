class UserPolicy < ApplicationPolicy

  def index?
    user.admin?
  end

  def show?
    edit?
  end

  def new?
    create?
  end

  def create?
    user.admin?
  end

  def edit?
    # Users can only edit their own profile
    # Admins can edit any user
    user == record || user.admin?
  end

  def update?
    edit?
  end

  def destroy?
    edit? || user.admin?
  end

  def lock?
    return false if user.is_a?(Doorkeeper::Application)
    user.admin? && !record.access_locked?
  end

  def unlock?
    return false if user.is_a?(Doorkeeper::Application)
    user.admin? && record.access_locked?
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