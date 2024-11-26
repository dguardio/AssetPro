class AssetTrackingEventPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.where(scanned_by: user)
      end
    end
  end

  def index?
    true
  end

  def show?
    user.admin? || record.scanned_by_id == user.id
  end

  def create?
    true
  end

  def update?
    user.admin? || record.scanned_by_id == user.id
  end

  def destroy?
    user.admin?
  end
end 