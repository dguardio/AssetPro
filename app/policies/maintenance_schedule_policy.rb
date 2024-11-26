class MaintenanceSchedulePolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    user.present?
  end

  def create?
    user.present?
  end

  def update?
    user.present?
  end

  def destroy?
    user.present?
  end

  # Add this method for the complete action
  def complete?
    return false unless user.present?
    
    # Allow admins to complete any maintenance schedule
    return true if user.admin?
    
    # Allow assigned users to complete their maintenance schedules
    record.assigned_to_id == user.id
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end 